import 'package:flutter/material.dart';

class ToggleBar extends StatelessWidget {
  final String selectedToggle;
  final Function(String) onToggleChanged;
  final bool
  showRioToggle; // CHANGE 1: Added parameter to control Rio toggle visibility

  const ToggleBar({
    Key? key,
    required this.selectedToggle,
    required this.onToggleChanged,
    this.showRioToggle =
        false, // CHANGE 2: Default to false (Rio toggle hidden by default)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSquareButton('top20'),
          SizedBox(height: 8),
          _buildSquareButton('states'),
          if (showRioToggle) ...[
            SizedBox(height: 8), // Add spacing before Rio
            _buildSquareButton('rio'),
          ],
          SizedBox(height: 8), // Optional: spacing at bottom
        ],
      ),
    );
  }

  Widget _buildSquareButton(String value) {
    final isSelected = selectedToggle == value;
    String label;

    switch (value) {
      case 'top20':
        label = 'Top 20 Brazil';
        break;
      case 'rio':
        label = 'Rio Top 10';
        break;
      case 'states':
        label = 'Brazil States';
        break;
      default:
        label = value;
    }

    return Container(
      width: 120,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onToggleChanged(value),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF374151) : Colors.white,
                border: Border.all(color: Color(0xFF374151), width: 1.5),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
