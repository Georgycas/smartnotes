import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../database/models/user_model.dart';
import '../../database/operations/system_operations.dart';
import '../../register_routes.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> with WidgetsBindingObserver {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkUserExists();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _checkUserExists() async {
    final user = await SystemOperations.getCurrentUser();
    if (user != null && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _saveOfflineUser() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      _showSnackbar("Nickname cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    final newUser = User(
      id: const Uuid().v4(),
      username: nickname,
      email: null,
      profilePicture: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await SystemOperations.upsertUser(newUser.toMap());
    await SystemOperations.markSetupComplete();

    if (!mounted) return;

    setState(() => _isLoading = true);
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Setup')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome! Set up your account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: "Enter Nickname",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveOfflineUser,
                icon: const Icon(Icons.person_off),
                label: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Continue Offline"),
              ),
              const SizedBox(height: 20),
              const Text(
                "Want to sync notes online?",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                icon: const Icon(Icons.cloud),
                label: const Text("Go Online (Sign in with Google)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
