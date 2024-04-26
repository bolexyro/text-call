import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:text_call/utils/utils.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/message-ring.svg',
              height: 200,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness == Brightness.dark
                      ? makeColorLighter(
                          Theme.of(context).colorScheme.primaryContainer, 100)
                      : Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Text Call',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 60,

                color: Colors.blue, // Set your desired text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
