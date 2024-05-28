import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ConfirmDiscardDialog extends StatelessWidget {
  const ConfirmDiscardDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog.adaptive(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 209, 205),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 171, 171),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/error.svg',
                height: 33,
                colorFilter: const ColorFilter.mode(
                    Color.fromARGB(255, 190, 19, 6), BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Discard changes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Are you sure you want to discard your changes? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 153, 153, 153),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 209, 209, 209),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 203, 51, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    'Discard',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
