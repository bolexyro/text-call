import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
      title: const Text('Pick a color!'),
      content: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(child: colorPikcer),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    material = !material;
                  });
                },
                child: const SizedBox(
                  height: 40,
                  width: 90,
                  child: Text(
                    'Change color picker',
                    maxLines: 2,
                    textAlign: TextAlign.center,
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
