// lib/widgets/line_selection_dialog.dart
import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class LineSelectionDialog extends StatefulWidget {
  final int initialLineNumber;
  final Function(int) onLineSelected;

  const LineSelectionDialog({
    Key? key,
    required this.initialLineNumber,
    required this.onLineSelected,
  }) : super(key: key);

  @override
  State<LineSelectionDialog> createState() => _LineSelectionDialogState();
}

class _LineSelectionDialogState extends State<LineSelectionDialog> {
  late int _selectedLine;

  @override
  void initState() {
    super.initState();
    _selectedLine = widget.initialLineNumber;
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    
    return AlertDialog(
      title: Text(
        'Select Production Line',
        style: TextStyle(
          fontSize: isTablet ? 20.0 : 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 1; i <= 4; i++)
            RadioListTile<int>(
              title: Text(
                'Line $i',
                style: TextStyle(
                  fontSize: isTablet ? 16.0 : 14.0,
                ),
              ),
              value: i,
              groupValue: _selectedLine,
              onChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    _selectedLine = value;
                  });
                }
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'CANCEL',
            style: TextStyle(
              fontSize: isTablet ? 16.0 : 14.0,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onLineSelected(_selectedLine);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text(
            'CONFIRM',
            style: TextStyle(
              fontSize: isTablet ? 16.0 : 14.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}