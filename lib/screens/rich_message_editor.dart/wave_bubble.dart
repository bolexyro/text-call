import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:text_call/utils/constants.dart';

import 'package:text_call/utils/utils.dart';

class WaveBubble extends StatefulWidget {
  const WaveBubble({
    super.key,
    required this.audioPath,
    required this.isNetworkAudio,
  });

  final String audioPath;
  final bool isNetworkAudio;

  @override
  State<WaveBubble> createState() => _WaveBubbleState();
}

class _WaveBubbleState extends State<WaveBubble> {
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  late final Future _variableToHoldInitializeAudioPlayerSourceFuture;

  Future<void> initializeAudioPlayerSource() async {
    if (widget.isNetworkAudio) {
      await _audioPlayer.setSourceUrl(widget.audioPath);
    } else {
      await _audioPlayer.setSourceDeviceFile(widget.audioPath);
    }

    _duration = await _audioPlayer.getDuration() ?? Duration.zero;

    // listen to states: playing, paused and stopped
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // listen to audio duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void initState() {
    _variableToHoldInitializeAudioPlayerSourceFuture =
        initializeAudioPlayerSource();

    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: kSpaceBtwWidgetsInPreviewOrRichTextEditor),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 110, 151, 183),
        border: Border.all(width: 2),
      ),
      height: 70,
      child: Center(
        child: FutureBuilder(
          future: _variableToHoldInitializeAudioPlayerSourceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return Row(
              children: [
                IconButton(
                  onPressed: () async {
                    if (_isPlaying) {
                      await _audioPlayer.pause();
                    } else {
                      await _audioPlayer.resume();
                    }
                  },
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Expanded(
                  child: _duration.inMilliseconds > 0
                      ? Slider(
                          min: 0,
                          max: _duration.inSeconds.toDouble(),
                          value: _position.inSeconds.toDouble(),
                          onChanged: (_) async {
                            final position = Duration(seconds: _.toInt());
                            await _audioPlayer.seek(position);
                          },
                        )
                      : const SizedBox(),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${formatDuration(_position)}/${formatDuration(_duration)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
