import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  final List<Map<String, dynamic>> _leaderboardData = const [
    {'rank': 1, 'name': 'Sarah Connor', 'steps': 14250, 'isCurrentUser': false},
    {'rank': 2, 'name': 'You', 'steps': 11820, 'isCurrentUser': true},
    {'rank': 3, 'name': 'John Doe', 'steps': 9450, 'isCurrentUser': false},
    {'rank': 4, 'name': 'Emma Watson', 'steps': 8300, 'isCurrentUser': false},
    {'rank': 5, 'name': 'Bruce Wayne', 'steps': 7210, 'isCurrentUser': false},
  ];

  Color _getBadgeColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),
        itemCount: _leaderboardData.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = _leaderboardData[index];
          final rank = user['rank'] as int;
          final isCurrent = user['isCurrentUser'] as bool;

          return Card(
            elevation: isCurrent ? 2 : 0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getBadgeColor(rank),
                foregroundColor: Colors.white,
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                user['name'] as String,
                style: TextStyle(
                  fontWeight: isCurrent
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_walk,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${user['steps']} steps',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}