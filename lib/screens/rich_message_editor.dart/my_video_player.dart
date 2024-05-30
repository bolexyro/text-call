import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
  // if not for preview, keyInMp and onDelete should be non null
  const MyVideoPlayer({
    super.key,
    required this.videoFile,
    this.keyInMap,
    this.onDelete,
    this.forPreview = false,
  });

  final File videoFile;
  final int? keyInMap;
  final void Function(int key)? onDelete;
  final bool forPreview;

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      widget.videoFile,
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    )
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      })
      ..setLooping(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            ],
          )
        : Container();
  }
}
