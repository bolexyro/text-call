import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class WaveBubble extends StatefulWidget {
  const WaveBubble({
    super.key,
    required this.audioPath,
  });

  final String audioPath;

  @override
  State<WaveBubble> createState() => _WaveBubbleState();
}

class _WaveBubbleState extends State<WaveBubble> {
  late PlayerController controller;
  late StreamSubscription _playerStateSubscription;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController()
      ..preparePlayer(
        path: widget.audioPath,
        shouldExtractWaveform: true,
      );
    _playerStateSubscription = controller.onPlayerStateChanged.listen(
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _playerStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 110, 151, 183),
        border: Border.all(width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!controller.playerState.isStopped)
            IconButton(
              onPressed: () async {
                controller.playerState.isPlaying
                    ? await controller.pausePlayer()
                    : await controller.startPlayer(
                        finishMode: FinishMode.pause,
                      );
              },
              icon: Icon(
                controller.playerState.isPlaying
                    ? Icons.stop
                    : Icons.play_arrow,
              ),
              color: Colors.white,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          Expanded(
            child: AudioFileWaveforms(
              padding: const EdgeInsets.only(right: 10),
              size: const Size(double.infinity, 70),
              playerController: controller,
              waveformType: WaveformType.fitWidth,
              playerWaveStyle: playerWaveStyle,
            ),
          ),
        ],
      ),
    );
  }
}
