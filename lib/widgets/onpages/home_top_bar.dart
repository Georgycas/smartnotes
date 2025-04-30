import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onRightIconPressed;
  final IconData? rightIcon;
  final List<Widget>? actions;
  final VoidCallback? onArchiveSelected;
  final VoidCallback? onDeleteSelected;

  const HomeAppBar({
    super.key,
    required this.title,
    this.onRightIconPressed,
    this.rightIcon,
    this.actions,
    this.onArchiveSelected,
    this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("TODO: Implement search page"),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
      
      
      actions: actions ?? [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onSelected: (value) {
            if (value == 'archive' && onArchiveSelected != null) {
              onArchiveSelected!();
            } else if (value == 'delete' && onDeleteSelected != null) {
              onDeleteSelected!();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'archive',
              child: Text('Archive'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
