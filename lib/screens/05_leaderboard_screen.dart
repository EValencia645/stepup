import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ModelProvider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load fresh data immediately when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLeaderboardData();
    });
  }

  Future<void> _fetchLeaderboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Fetch all StepRecord rows from DynamoDB
      final request = ModelQueries.list(
        StepRecord.classType,
        limit: 1000,
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        debugPrint('>>> GRAPHQL ERRORS: ${response.errors}');
      }

      final records = response.data?.items.whereType<StepRecord>().toList() ?? [];

      debugPrint('>>> ACTUAL ITEMS FETCHED FROM DYNAMODB: ${records.length}');

      if (records.isEmpty) {
        if (!mounted) return;
        setState(() {
          _leaderboardData = [];
          _isLoading = false;
        });
        return;
      }

      // 2. Sum up all step records directly from DB
      int totalSteps = 0;
      for (final record in records) {
        totalSteps += record.stepCount;
        debugPrint('Record ID: ${record.id} | Steps: ${record.stepCount}');
      }

      debugPrint('>>> FINAL CALCULATED TOTAL: $totalSteps');

      // 3. Clean UI display - No UUIDs, no long strings
      final List<Map<String, dynamic>> formattedList = [
        {
          'rank': 1,
          'name': 'You',
          'steps': totalSteps,
          'isCurrentUser': true,
        }
      ];

      if (!mounted) return;
      setState(() {
        _leaderboardData = formattedList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('>>> LEADERBOARD FETCH ERROR: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
        elevation: 1,
        actions: [
          IconButton(
            tooltip: 'Refresh Leaderboard',
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLeaderboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching latest scores from AWS...'),
                ],
              ),
            )
          : _leaderboardData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_walk, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No step records found in AWS.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Check Again'),
                        onPressed: _fetchLeaderboardData,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchLeaderboardData,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                        elevation: isCurrent ? 3 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: isCurrent
                              ? BorderSide(color: Theme.of(context).primaryColor, width: 1.5)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: _getBadgeColor(rank),
                            foregroundColor: Colors.white,
                            child: Text(
                              '#$rank',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            user['name'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.directions_walk,
                                size: 22,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${user['steps']} steps',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}