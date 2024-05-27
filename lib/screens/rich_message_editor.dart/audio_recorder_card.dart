import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AudioRecorderCard extends StatefulWidget {
  const AudioRecorderCard({super.key});

  @override
  State<AudioRecorderCard> createState() => _AudioRecorderCardState();
}

class _AudioRecorderCardState extends State<AudioRecorderCard> {
  late final RecorderController recorderController;

  String? path;
  String? musicFile;
  bool _isRecording = false;
  bool isRecordingCompleted = false;

  @override
  void initState() {
    super.initState();
    _initialiseControllers();
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  void _stopRecording() async {
    try {
      recorderController.reset();
      path = await recorderController.stop(false);

      if (path != null) {
        isRecordingCompleted = true;
        debugPrint('path is $path');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _startOrPauseRecording() async {
    try {
      if (_isRecording) {
        await recorderController.pause();
      } else {
        await recorderController.record(path: path); // Path is optional
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isRecording = !_isRecording;
      });
    }
  }

  void _refreshWave() async{
    if (_isRecording) {
      await recorderController.stop();
      await recorderController.record();
    }
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Card(
            elevation: 0,
            color: const Color.fromARGB(225, 229, 238, 249),
            child: Column(
              children: [
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isRecording
                      ? AudioWaveforms(
                          enableGesture: true,
                          size:
                              Size(MediaQuery.of(context).size.width / 1.2, 50),
                          recorderController: recorderController,
                          waveStyle: const WaveStyle(
                            waveColor: Colors.white,
                            extendWaveform: true,
                            showMiddleLine: false,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: const Color.fromARGB(255, 110, 151, 183),
                          ),
                          padding: const EdgeInsets.only(left: 18),
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 110, 151, 183),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.only(left: 18),
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                        ),
                ),
                const Gap(5),
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
                    }),
                const Gap(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _refreshWave,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 8.0),
                        decoration: const ShapeDecoration(
                          shape: StadiumBorder(),
                          color: Colors.white,
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.refresh,
                              color: Color.fromARGB(255, 113, 139, 207),
                            ),
                            Gap(5),
                            Text(
                              'Restart',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 113, 139, 207),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RecordButton(
                      isRecording: _isRecording,
                      onTap: _startOrPauseRecording,
                    ),
                    GestureDetector(
                      onTap: _stopRecording,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 8.0),
                        decoration: const ShapeDecoration(
                          shape: StadiumBorder(),
                          color: Colors.white,
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.stop,
                              color: Color.fromARGB(255, 45, 59, 78),
                            ),
                            Gap(5),
                            Text(
                              'Stop',
                              style: TextStyle(
                                color: Color.fromARGB(255, 45, 59, 78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 255, 57, 43),
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
