import 'package:flutter/material.dart';

class CrudAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String pageType;
  final VoidCallback onBack;
  final VoidCallback onDelete;

  const CrudAppBar({
    super.key,
    required this.pageType,
    required this.onBack,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Disable default back button
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      title: Text(
        "New ${pageType[0].toUpperCase()}${pageType.substring(1)}",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ],
      elevation: 2,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
