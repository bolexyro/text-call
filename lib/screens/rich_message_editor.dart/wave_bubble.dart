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
  late PlayerController _playerController;
  late StreamSubscription _playerStateSubscription;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController()
      ..preparePlayer(
        path: widget.audioPath,
        shouldExtractWaveform: true,
      );
    _playerStateSubscription = _playerController.onPlayerStateChanged.listen(
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _playerController.dispose();
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
          if (!_playerController.playerState.isStopped)
            IconButton(
              onPressed: () async {
                _playerController.playerState.isPlaying
                    ? await _playerController.pausePlayer()
                    : await _playerController.startPlayer(
                        finishMode: FinishMode.pause,
                      );
              },
              icon: Icon(
                _playerController.playerState.isPlaying
                    ? Icons.stop
                    : Icons.play_arrow,
              ),
              color: Colors.white,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          Expanded(
            child: Column(
              children: [
                AudioFileWaveforms(
                  enableSeekGesture: true,
                  padding: const EdgeInsets.only(right: 10),
                  size: const Size(double.infinity, 70),
                  playerController: _playerController,
                  waveformType: WaveformType.fitWidth,
                  playerWaveStyle: playerWaveStyle,
                ),
                Text(widget.audioPath),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
