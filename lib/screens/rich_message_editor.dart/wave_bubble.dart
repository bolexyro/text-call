import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:text_call/utils/constants.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:http/http.dart' as http;

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
  late PlayerController _playerController;
  late StreamSubscription _playerStateSubscription;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,
  );

  Future<void> _loadRemoteAudioToTempDir() async {
    final response = await http.get(Uri.parse(widget.audioPath));
    final bytes = response.bodyBytes;
    final Directory tempDir = await path_provider.getTemporaryDirectory();
    final String newFileName =
        FirebaseStorage.instance.refFromURL(widget.audioPath).name;
    final file = File('${tempDir.path}/$newFileName');

    if (response.statusCode == 200) {
      await file.writeAsBytes(bytes);
      _playerController = PlayerController()
        ..preparePlayer(path: file.path, shouldExtractWaveform: true);
      _playerStateSubscription =
          _playerController.onPlayerStateChanged.listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  late final Future _variableForHoldingloadRemoteAudioToTempDirFuture;
  @override
  void initState() {
    super.initState();

    if (widget.isNetworkAudio) {
      _variableForHoldingloadRemoteAudioToTempDirFuture =
          _loadRemoteAudioToTempDir();
      return;
    }
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
      margin: const EdgeInsets.only(
          bottom: kSpaceBtwWidgetsInPreviewOrRichTextEditor),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 110, 151, 183),
        border: Border.all(width: 2),
      ),
      child: widget.isNetworkAudio
          ? FutureBuilder(
              future: _variableForHoldingloadRemoteAudioToTempDirFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.play_arrow,
                        ),
                        color: Colors.white,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 18.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      child: AudioFileWaveforms(
                        enableSeekGesture: true,
                        padding: const EdgeInsets.only(right: 10),
                        size: const Size(double.infinity, 70),
                        playerController: _playerController,
                        waveformType: WaveformType.fitWidth,
                        playerWaveStyle: playerWaveStyle,
                      ),
                    ),
                  ],
                );
              },
            )
          : Row(
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
                  child: AudioFileWaveforms(
                    enableSeekGesture: true,
                    padding: const EdgeInsets.only(right: 10),
                    size: const Size(double.infinity, 70),
                    playerController: _playerController,
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: playerWaveStyle,
                  ),
                ),
              ],
            ),
    );
  }
}
