import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController? labelController;
  final bool readOnly;

  const TextInput({
    super.key,
    required this.titleController,
    required this.contentController,
    this.labelController,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: titleController,
            readOnly: readOnly,
            decoration: const InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: contentController,
            readOnly: readOnly,
            maxLines: 10,
            minLines: 4,
            decoration: const InputDecoration(
              labelText: "Write something...",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (labelController != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: labelController,
              readOnly: readOnly,
              decoration: const InputDecoration(
                labelText: "Label (optional)",
                border: OutlineInputBorder(),
              ),
            ),
          ),
      ],
    );
  }
}
