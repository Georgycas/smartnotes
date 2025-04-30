import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key, required this.labels});

  final List<String> labels;

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pop(context); // Close drawer
    Navigator.pushNamed(context, routeName); // Just push, no replacement
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
            ),
            height: 120,
            child: const Center(
              child: Text(
                'Smart Notes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.sticky_note_2,
                  text: 'All Notes',
                  onTap: () => _navigateTo(context, '/notes'),
                ),

                const Divider(height: 25, thickness: 1),

                _buildSectionTitle('Labels', Icons.label_outline),
                if (labels.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'No labels yet',
                      style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  ...labels.map((label) => _buildDrawerItem(
                        icon: Icons.label,
                        text: label,
                        onTap: () {
                          // TODO: Implement label filter later
                        },
                      )),

                const Divider(height: 25, thickness: 1),

                _buildDrawerItem(
                  icon: Icons.archive,
                  text: 'Archive',
                  onTap: () => _navigateTo(context, '/archive'),
                ),
                _buildDrawerItem(
                  icon: Icons.delete,
                  text: 'Trash',
                  onTap: () => _navigateTo(context, '/trash'),
                ),


                const Divider(height: 25, thickness: 1),

                _buildDrawerItem(
                  icon: Icons.settings,
                  text: 'Settings',
                  onTap: () => _navigateTo(context, '/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        onTap: onTap,
        tileColor: Colors.grey[200],
        hoverColor: Colors.grey[300],
      ),
    );
  }
}
