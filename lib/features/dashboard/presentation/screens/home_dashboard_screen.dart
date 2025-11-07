import 'package:flutter/material.dart';

/// Home dashboard screen placeholder
///
/// This is a temporary placeholder for testing authentication flow.
/// Full implementation will be done in a separate feature.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 24),
            Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Home dashboard will be implemented here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
