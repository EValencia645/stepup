import 'package:flutter/material.dart';
import '04_add_steps_screen.dart';
import 'package:stepup/screens/05_leaderboard_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalSteps = 0;

  // Navigates to Screen 04 and receives the added steps back
  Future<void> _navigateToAddSteps() async {
  final addedSteps = await Navigator.push<int>(
    context,
    MaterialPageRoute(
      builder: (context) => const AddStepsScreen(),
    ),
  );

  if (addedSteps != null) {
    setState(() {
      _totalSteps += addedSteps;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$addedSteps steps added successfully!',
          ),
        ),
      );
    }
  }
}

  // Navigates to Screen 05
  void _navigateToLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Total Steps Today',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '$_totalSteps',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _navigateToAddSteps,
                icon: const Icon(Icons.add),
                label: const Text('Add Steps'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _navigateToLeaderboard,
                icon: const Icon(Icons.leaderboard),
                label: const Text('View Leaderboard'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}