import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:text_call/screens/rich_message_editor.dart/wave_bubble.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';

class AudioRecorderCard extends StatefulWidget {
  const AudioRecorderCard({
    super.key,
    required this.onDelete,
    required this.keyInMap,
    required this.savePath,
    this.initialAudioPath,
  });

  final int keyInMap;
  final String? initialAudioPath;
  final void Function(int key) onDelete;
  final void Function(String? path, int key) savePath;

  @override
  State<AudioRecorderCard> createState() => _AudioRecorderCardState();
}

class _AudioRecorderCardState extends State<AudioRecorderCard> {
  late final RecorderController recorderController;

  String? _path;
  bool _isRecording = false;
  bool _recordingStarted = false;
  late Future<String> _recordingDirectory;

  @override
  void initState() {
    if (widget.initialAudioPath != null) {
      _recordingStarted = true;
      _path = widget.initialAudioPath!;
    }
    _recordingDirectory =
        messageWriterDirectoryPath(specificDirectory: 'audio');
    _initialiseControllers();
    super.initState();
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
    ..androidEncoder = AndroidEncoder.aac
    ..androidOutputFormat = AndroidOutputFormat.mpeg4
    ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
    ..sampleRate = 44100
    ..bitRate = 48000;

  }

  void _stopRecording() async {
    try {
      recorderController.reset();
      final String? localPath = await recorderController.stop(false);

      if (localPath != null) {
        widget.savePath(localPath, widget.keyInMap);
        _path = localPath;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isRecording = false;
        _recordingStarted = false;
      });
    }
  }

  void _startOrPauseRecording() async {
    try {
      if (_isRecording) {
        await recorderController.pause();
      } else {
        final formattedDate = DateTime.now()
            .toIso8601String()
            .replaceAll(':', '-')
            .replaceAll('.', '-');
        final fileName = '${await _recordingDirectory}/$formattedDate.m4a';
        await recorderController.record(path: fileName); // Path is optional
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        if (_recordingStarted == false) {
          _recordingStarted = true;
        }
        _isRecording = !_isRecording;
      });
    }
  }

  void _restart() async {
    if (_isRecording) {
      await recorderController.stop();
      await recorderController.record();
    }
  }

  void _takeAnotherAudio() {
    widget.savePath(null, widget.keyInMap);
    setState(() {
      _path = null;
      _isRecording = false;
      _recordingStarted = false;
    });
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: kSpaceBtwWidgetsInPreviewOrRichTextEditor),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(225, 229, 238, 249),
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _path == null
                        ? AudioWaveforms(
                            enableGesture: true,
                            size: const Size(double.infinity, 70),
                            recorderController: recorderController,
                            waveStyle: const WaveStyle(
                              waveColor: Colors.white,
                              extendWaveform: true,
                              showMiddleLine: false,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: const Color.fromARGB(255, 110, 151, 183),
                              border: Border.all(width: 2),
                            ),
                            padding: const EdgeInsets.only(left: 18),
                          )
                        : WaveBubble(audioPath: _path!),
                  ),
                ),
                const Gap(5),
                if (_path == null)
                  StreamBuilder<Duration>(
                    stream: recorderController.onCurrentDuration,
                    builder: (context, snapshot) {
                      final duration = snapshot.data ?? Duration.zero;
                      String twoDigits(int n) => n.toString().padLeft(2, '0');
                      final twoDigitsMinute =
                          twoDigits(duration.inMinutes.remainder(60));

                      final twoDigitsSecond =
                          twoDigits(duration.inSeconds.remainder(60));
                      return Text(
                        '$twoDigitsMinute:$twoDigitsSecond',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 45, 59, 78),
                            fontSize: 20),
                      );
                    },
                  ),
                if (_path != null) const SizedBox(height: 28),
                const Gap(5),
                if (_path != null)
                  Center(
                    child: GestureDetector(
                      onTap: _takeAnotherAudio,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(223, 178, 200, 228),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 153, 193, 224),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.refresh,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_path == null)
                  LayoutBuilder(builder: (context, constraints) {
                    final eachWidgetsWidth = constraints.maxWidth / 3;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: eachWidgetsWidth,
                          child: Center(
                            child: Opacity(
                              opacity: _isRecording ? 1 : 0.0,
                              child: GestureDetector(
                                onTap: _isRecording ? _restart : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 12.0),
                                  decoration: const ShapeDecoration(
                                    shape: StadiumBorder(),
                                    color: Colors.white,
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh,
                                        color:
                                            Color.fromARGB(255, 113, 139, 207),
                                      ),
                                      Gap(5),
                                      Text(
                                        'Restart',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 113, 139, 207),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: eachWidgetsWidth,
                          child: RecordButton(
                            isRecording: _isRecording,
                            onTap: _startOrPauseRecording,
                          ),
                        ),
                        SizedBox(
                          width: eachWidgetsWidth,
                          child: Center(
                            child: Opacity(
                              opacity: _recordingStarted ? 1 : 0.0,
                              child: GestureDetector(
                                onTap: _stopRecording,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 12.0),
                                  decoration: const ShapeDecoration(
                                    shape: StadiumBorder(),
                                    color: Colors.white,
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.stop,
                                        color: Color.fromARGB(255, 45, 59, 78),
                                      ),
                                      Gap(5),
                                      Text(
                                        'Stop',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 59, 78),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(
            right: -10,
            top: -10,
            child: GestureDetector(
              onTap: () => widget.onDelete(widget.keyInMap),
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
      ),
    );
  }
}

class RecordButton extends StatelessWidget {
  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  final bool isRecording;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        padding: isRecording ? null : const EdgeInsets.all(7),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: isRecording
              ? const Icon(
                  Icons.pause,
                  size: 35,
                  color: Colors.black,
                )
              : Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
        ),
      ),
    );
  }
}
