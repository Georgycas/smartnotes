import 'package:flutter/material.dart';
import '../../register_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Mode Setup'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_done, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'Sign in with your Google account to enable online sync.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Placeholder login button
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Replace with actual Firebase Auth logic
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to offline setup
                },
                child: const Text("Back to Offline Setup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
