import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
  // if not for preview, keyInMp and onDelete should be non null
  const MyVideoPlayer({
    super.key,
    required this.videoPath,
    this.keyInMap,
    this.onDelete,
    this.forPreview = false,
    required this.networkVideo,
  });

  final String videoPath;
  final int? keyInMap;
  final void Function(int key)? onDelete;
  final bool forPreview;
  final bool networkVideo;

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;
  late Duration _videoDuration;

  @override
  void initState() {
    super.initState();
    _controller = widget.networkVideo
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
        : VideoPlayerController.file(
            File(widget.videoPath),
            videoPlayerOptions:
                VideoPlayerOptions(allowBackgroundPlayback: true),
          )
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _videoDuration = _controller.value.duration;
      })
      ..setLooping(false);
    _controller.addListener(_checkVideoCompletion);
  }

  void _checkVideoCompletion() {
    if (_controller.value.position == _controller.value.duration) {
      setState(() {
        _controller.seekTo(Duration.zero);
        _videoDuration = Duration.zero;
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

  final videoIsDone = false;

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2),
                    ),
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),
              if (!widget.forPreview)
                Positioned(
                  right: -10,
                  top: -10,
                  child: GestureDetector(
                    onTap: () => widget.onDelete!(widget.keyInMap!),
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
                child: Container(
                  decoration: const ShapeDecoration(
                    shape: StadiumBorder(),
                    color: Colors.black54,
                  ),
                  padding: const EdgeInsets.fromLTRB(5, 0, 8, 0),
                  child: !_controller.value.isPlaying
                      ? Row(
                          children: [
                            const Icon(Icons.play_arrow),
                            Text(
                              _formatDuration(_videoDuration),
                            ),
                          ],
                        )
                      : ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (BuildContext context,
                              VideoPlayerValue value, Widget? child) {
                            return Row(
                              children: [
                                const Icon(Icons.pause),
                                Text(
                                  _formatDuration(value.position),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              )
            ],
          )
        : Container();
  }
}
