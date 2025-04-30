//TODO mothball: Implement vault functionality
import 'package:flutter/material.dart';
import '../../register_widgets.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  bool _isActionMode = false;

  void _toggleAppBar() {
    setState(() => _isActionMode = !_isActionMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isActionMode ? _buildActionAppBar() : HomeAppBar(title: 'Vault'),
      drawer: _isActionMode ? null : HomeDrawer(labels: []),
      body: _buildPlaceholderContent(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _toggleAppBar,
            tooltip: "Switch AppBar",
            child: const Icon(Icons.swap_horiz),
          ),
          const SizedBox(height: 10),
          if (_isActionMode)
            FloatingActionButton.extended(
              onPressed: () {
                // TODO: Implement unlock vault logic
              },
              icon: const Icon(Icons.lock_open),
              label: const Text("Unlock"),
            ),
        ],
      ),
    );
  }

  AppBar _buildActionAppBar() {
    return AppBar(
      title: const Text('Vault Actions'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _toggleAppBar,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.security),
          onPressed: () {
            // TODO: Implement security/encryption logic
          },
          tooltip: "Security",
        ),
        IconButton(
          icon: const Icon(Icons.visibility_off),
          onPressed: () {
            // TODO: Hide selected vault content
          },
          tooltip: "Hide",
        ),
      ],
    );
  }

  Widget _buildPlaceholderContent() {
    return const Center(
      child: Text(
        "Your secured notes will appear here...\n(Vault functionality coming soon)",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }
}
