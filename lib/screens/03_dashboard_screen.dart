import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:lottie/lottie.dart';
import '../models/ModelProvider.dart';
import '04_add_steps_screen.dart';
import '06_my_records_screen.dart';
import '07_teams_screen.dart';
import 'package:stepup/screens/05_leaderboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalSteps = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTotalSteps();
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
      debugPrint('Could not fetch user attributes: $e');
    }
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user.username;
    } catch (e) {
      return 'User';
    }
  }

  /// Loads the current user's total steps from DynamoDB on screen mount.
  Future<void> _loadTotalSteps() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Get current user's display name (email) to match stored records
      final currentUserName = await _getDisplayName();

      // Query all StepRecords for this user
      final request = ModelQueries.list(
        StepRecord.classType,
        limit: 1000,
      );
      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        debugPrint('>>> DASHBOARD LOAD ERRORS: ${response.errors}');
      }

      final records = response.data?.items.whereType<StepRecord>().toList() ?? [];

      // Sum only the current user's records
      int total = 0;
      for (final record in records) {
        if (record.userName == currentUserName) {
          total += record.stepCount;
        }
      }

      if (mounted) {
        setState(() {
          _totalSteps = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('>>> DASHBOARD LOAD ERROR: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
            content: Text('$addedSteps steps added successfully!'),
          ),
        );
      }
    }
  }

  // Navigates to Screen 06 (My Records) and reloads totals on return
  Future<void> _navigateToMyRecords() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyRecordsScreen(),
      ),
    );
    // Always reload — user may have edited or deleted records
    await _loadTotalSteps();
  }

  // Navigates to Teams screen
  void _navigateToTeams() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeamsScreen()),
    );
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

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Amplify.Auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadTotalSteps,
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Walking animation
              Lottie.asset(
                'assets/animations/walking.json',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              const Text(
                'Total Steps',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      '$_totalSteps',
                      style: const TextStyle(
                        fontSize: 56,
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
              ElevatedButton.icon(
                onPressed: _navigateToMyRecords,
                icon: const Icon(Icons.list_alt),
                label: const Text('My Records'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _navigateToTeams,
                icon: const Icon(Icons.group),
                label: const Text('Teams'),
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