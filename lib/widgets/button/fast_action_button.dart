import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final void Function(String widgetType) onAdd;

  const ActionButtons({super.key, required this.onAdd});

  void _showFabMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ Important!
              children: [
                _buildButton(context, Icons.edit, "Text", Colors.green, 'text'),
                const SizedBox(height: 12),
                _buildButton(
                  context,
                  Icons.mic,
                  "Recording",
                  Colors.red,
                  'recording',
                ),
                const SizedBox(height: 12),
                _buildButton(
                  context,
                  Icons.image,
                  "Image",
                  Colors.blue,
                  'image',
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    String widgetType,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pop(context); // Close modal
        onAdd(widgetType); // Callback to open editor
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showFabMenu(context),
      tooltip: "New Note",
      child: const Icon(Icons.add),
    );
  }
}
