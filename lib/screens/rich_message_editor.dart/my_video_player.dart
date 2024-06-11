import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/utils/constants.dart';
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

  String _formatDuration(Duration duration) {
    int totalSeconds = duration.inSeconds;
    int seconds = totalSeconds % 60;
    int totalMinutes = totalSeconds ~/ 60;
    int minutes = totalMinutes % 60;
    int hours = totalMinutes ~/ 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _goFullScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(
          videoPath: widget.videoPath,
          videoController: _controller,
          formatDuration: _formatDuration,
        ),
      ),
    );
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
                    formatDuration: _formatDuration,
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

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late TransformationController _transformationController;
  double _currentScale = 1.0;

  @override
  void initState() {
    widget.videoController.addListener(_checkVideoCompletion);
    _transformationController = TransformationController();
    super.initState();
  }

  @override
  void dispose() {
    widget.videoController.removeListener(_checkVideoCompletion);
    _transformationController.dispose();
    super.dispose();
  }

  void _checkVideoCompletion() {
    if (widget.videoController.value.position ==
        widget.videoController.value.duration) {
      setState(() {
        widget.videoController.seekTo(Duration.zero);
      });
    }
  }

  void _handleDoubleTap(TapDownDetails details) {
    final position = details.localPosition;
    final scale = _currentScale > 1.0 ? 1.0 : 2.0;
    setState(() {
      _currentScale = scale;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * (scale - 1), -position.dy * (scale - 1))
        ..scale(scale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTap,
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
