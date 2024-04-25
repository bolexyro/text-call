import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:text_call/utils/utils.dart';

class ChooseColorDialog extends StatefulWidget {
  const ChooseColorDialog({
    super.key,
    required this.initialPickerColor,
  });

  final Color initialPickerColor;

  @override
  State<ChooseColorDialog> createState() => _ChooseColorDialogState();
}

class _ChooseColorDialogState extends State<ChooseColorDialog> {
  late Color pickerColor;

  @override
  void initState() {
    pickerColor = widget.initialPickerColor;
    super.initState();
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  bool material = false;

  @override
  Widget build(BuildContext context) {
    late Widget colorPikcer;
    if (material) {
      colorPikcer = MaterialPicker(
        pickerColor: pickerColor,
        onColorChanged: changeColor,
      );
    } else {
      colorPikcer = ColorPicker(
        pickerColor: pickerColor,
        onColorChanged: changeColor,
        enableAlpha: false,
        labelTypes: const [],
      );
    }

    return AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ?makeColorLighter(Theme.of(context)
              .colorScheme.inversePrimary, -135) 
              
          : null,
      title: const Text('Pick a color!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 370,
            child: SingleChildScrollView(child: colorPikcer),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    material = !material;
                  });
                },
                child: const SizedBox(
                  height: 60,
                  width: 90,
                  child: Center(
                    child: Text(
                      'Change color picker',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              ElevatedButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop(pickerColor);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
