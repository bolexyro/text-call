import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({
    super.key,
    required this.videoPath,
    this.keyInMap,
    this.onDelete,
    this.forPreview = false,
    required this.isNetworkVideo,
  });

  final String videoPath;
  final int? keyInMap;
  final void Function(int key)? onDelete;
  final bool forPreview;
  final bool isNetworkVideo;

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late dynamic _controller;

  @override
  void initState() {
    super.initState();

    if (widget.isNetworkVideo) {
      _controller = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(widget.videoPath),
      )
        ..initialize().then((_) {
          setState(() {});
        })
        ..setLooping(false);
    } else {
      _controller = VideoPlayerController.file(
        File(widget.videoPath),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
      )
        ..initialize().then((_) {
          setState(() {});
        })
        ..setLooping(false);
    }
    _controller.addListener(_checkVideoCompletion);
  }

  void _checkVideoCompletion() {
    if (_controller.value.position == _controller.value.duration) {
      setState(() {
        _controller.seekTo(Duration.zero);
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkVideoCompletion);
    _controller.dispose();
    super.dispose();
  }

  void _goFullScreen() async {
    _controller = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullScreenVideoPlayer(
              videoPath: widget.videoPath,
              videoController: _controller,
              formatDuration: formatDuration,
            ),
          ),
        ) ??
        _controller;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? SizedBox(
            height: 400,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: kSpaceBtwWidgetsInPreviewOrRichTextEditor),
                  child: GestureDetector(
                    onDoubleTap: _goFullScreen,
                    onTap: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(width: 2),
                      ),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: Hero(
                                tag: widget.videoPath,
                                child: widget.isNetworkVideo
                                    ? CachedVideoPlayerPlus(_controller)
                                    : VideoPlayer(_controller),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!widget.forPreview)
                  Positioned(
                    right: -10,
                    top: -10,
                    child: GestureDetector(
                      onTap: () => widget.onDelete!(
                        widget.keyInMap!,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/delete.svg',
                          colorFilter: const ColorFilter.mode(
                            Color.fromARGB(255, 255, 57, 43),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 5,
                  top: 5,
                  child: VideoStatusDisplay(
                    controller: _controller,
                    formatDuration: formatDuration,
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: _goFullScreen,
                    child: SvgPicture.asset(
                      'assets/icons/full-screen.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      height: kIconHeight,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox(
            height: 400,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  const FullScreenVideoPlayer({
    super.key,
    required this.videoPath,
    required this.videoController,
    required this.formatDuration,
  });

  final String videoPath;
  final dynamic videoController;
  final String Function(Duration duration) formatDuration;

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  double get _scale => _transformationController.value.row0.x;
  late Offset _doubleTapLocalPosition;
  final minScale = 1.0;
  final maxScale = 3.0;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  Offset? _dragOffset;
  Offset? _previousPosition;
  bool _enableDrag = true;

  @override
  void initState() {
    widget.videoController.addListener(_checkVideoCompletion);
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        _transformationController.value =
            _animation?.value ?? Matrix4.identity();
      });
    super.initState();
  }

  @override
  void dispose() {
    widget.videoController.removeListener(_checkVideoCompletion);
    _transformationController.dispose();
    _animationController.dispose();

    super.dispose();
  }

  void _onDragStart(ScaleStartDetails scaleDetails) {
    _previousPosition = scaleDetails.focalPoint;
  }

  void _onDragUpdate(ScaleUpdateDetails scaleUpdateDetails) {
    final currentPosition = scaleUpdateDetails.focalPoint;
    final previousPosition = _previousPosition ?? currentPosition;

    final newY =
        (_dragOffset?.dy ?? 0.0) + (currentPosition.dy - previousPosition.dy);
    _previousPosition = currentPosition;
    if (_enableDrag) {
      setState(() {
        _dragOffset = Offset(0, newY);
      });
    }
  }

  void _onOverScrollDragEnd(ScaleEndDetails? scaleEndDetails) {
    if (_dragOffset == null) return;
    final dragOffset = _dragOffset!;

    final screenSize = MediaQuery.of(context).size;

    if (scaleEndDetails != null) {
      if (dragOffset.dy.abs() >= screenSize.height / 3) {
        Navigator.of(context).pop();
        return;
      }
      final velocity = scaleEndDetails.velocity.pixelsPerSecond;
      final velocityY = velocity.dy;

      const thresholdOffsetYToEnablePop = 75.0;
      const thresholdVelocityYToEnablePop = 200.0;
      if (velocityY.abs() > thresholdOffsetYToEnablePop &&
          dragOffset.dy.abs() > thresholdVelocityYToEnablePop &&
          _enableDrag) {
        Navigator.of(context).pop();
        return;
      }
    }
  }

  void _onDoubleTap() {
    Matrix4 matrix = _transformationController.value.clone();

    final double currentScale = matrix.row0.x;
    double targetScale = minScale;

    if (currentScale <= minScale) {
      targetScale = maxScale;
    }
    final double offSetX = targetScale == minScale
        ? 0.0
        : -_doubleTapLocalPosition.dx * (targetScale - 1);
    final double offSetY = targetScale == minScale
        ? 0.0
        : -_doubleTapLocalPosition.dy * (targetScale - 1);

    matrix = Matrix4.fromList([
      targetScale,
      matrix.row1.x,
      matrix.row2.x,
      matrix.row3.x,
      matrix.row0.y,
      targetScale,
      matrix.row2.y,
      matrix.row3.y,
      matrix.row0.z,
      matrix.row1.z,
      targetScale,
      matrix.row3.z,
      offSetX,
      offSetY,
      matrix.row2.w,
      matrix.row3.w
    ]);

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: matrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }

  void _checkVideoCompletion() {
    if (widget.videoController.value.position ==
        widget.videoController.value.duration) {
      setState(() {
        widget.videoController.seekTo(Duration.zero);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(widget.videoController);
      },
      child: GestureDetector(
        onDoubleTapDown: (TapDownDetails details) =>
            _doubleTapLocalPosition = details.localPosition,
        onDoubleTap: _onDoubleTap,
        onTap: () {
          setState(() {
            widget.videoController.value.isPlaying
                ? widget.videoController.pause()
                : widget.videoController.play();
          });
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: InteractiveViewer(
              transformationController: _transformationController,
              onInteractionUpdate: (details) {
                _onDragUpdate(details);
                if (_scale == 1.0) {
                  _enableDrag = true;
                } else {
                  _enableDrag = false;
                }
                setState(() {});
              },
              onInteractionEnd: (details) {
                if (_enableDrag) {
                  _onOverScrollDragEnd(details);
                }
              },
              onInteractionStart: (details) {
                if (_enableDrag) {
                  _onDragStart(details);
                }
              },
              child: Center(
                child: Stack(
                  children: [
                    Hero(
                      tag: widget.videoPath,
                      child: AspectRatio(
                        aspectRatio: widget.videoController.value.aspectRatio,
                        child: VideoPlayer(widget.videoController),
                      ),
                    ),
                    Positioned(
                      left: 5,
                      top: 5,
                      child: VideoStatusDisplay(
                        controller: widget.videoController,
                        formatDuration: widget.formatDuration,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoStatusDisplay extends StatelessWidget {
  const VideoStatusDisplay({
    super.key,
    required this.controller,
    required this.formatDuration,
  });

  final dynamic controller;
  final String Function(Duration duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        color: Colors.white54,
      ),
      padding: const EdgeInsets.fromLTRB(5, 0, 8, 0),
      child: !controller.value.isPlaying
          ? Row(
              children: [
                const Icon(Icons.play_arrow),
                Text(
                  formatDuration(
                    controller.value.position == Duration.zero
                        ? controller.value.duration
                        : controller.value.position,
                  ),
                ),
              ],
            )
          : controller.runtimeType == CachedVideoPlayerPlusController
              ? ValueListenableBuilder(
                  valueListenable:
                      controller as CachedVideoPlayerPlusController,
                  builder: (BuildContext context,
                      CachedVideoPlayerPlusValue value, Widget? child) {
                    return Row(
                      children: [
                        const Icon(Icons.pause),
                        Text(
                          formatDuration(value.position),
                        ),
                      ],
                    );
                  },
                )
              : ValueListenableBuilder(
                  valueListenable: controller as VideoPlayerController,
                  builder: (BuildContext context, VideoPlayerValue value,
                      Widget? child) {
                    return Row(
                      children: [
                        const Icon(Icons.pause),
                        Text(
                          formatDuration(value.position),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
