import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:lottie/lottie.dart';
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

  /// Returns the user's email address as their display name.
  /// Falls back to the Cognito username if attributes can't be fetched.
  Future<String> _getDisplayName() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final emailAttr = attributes.firstWhere(
        (a) => a.userAttributeKey == CognitoUserAttributeKey.email,
        orElse: () => const AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.email,
          value: '',
        ),
      );
      if (emailAttr.value.isNotEmpty) return emailAttr.value;
    } catch (e) {
      debugPrint('>>> Could not fetch user attributes: $e');
    }
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user.username;
    } catch (e) {
      return 'User';
    }
  }

  Future<void> _fetchLeaderboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Get the current authenticated user's display name (email)
      final currentUserName = await _getDisplayName();

      // 2. Fetch all StepRecord rows from DynamoDB
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

      // 3. Group step counts by userName
      final Map<String, int> stepsByUser = {};
      for (final record in records) {
        final name = record.userName;
        stepsByUser[name] = (stepsByUser[name] ?? 0) + record.stepCount;
        debugPrint('User: $name | Record steps: ${record.stepCount}');
      }

      // 4. Sort users by total steps descending and assign ranks
      final sortedUsers = stepsByUser.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final List<Map<String, dynamic>> formattedList = [];
      for (int i = 0; i < sortedUsers.length; i++) {
        final entry = sortedUsers[i];
        final isCurrentUser = entry.key == currentUserName;
        formattedList.add({
          'rank': i + 1,
          'name': isCurrentUser ? 'You' : entry.key,
          'steps': entry.value,
          'isCurrentUser': isCurrentUser,
        });
        debugPrint('Rank ${i + 1}: ${entry.key} | Total steps: ${entry.value}');
      }

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
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                      Lottie.asset(
                        'assets/animations/empty.json',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const Text(
                        'No steps logged yet.',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
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