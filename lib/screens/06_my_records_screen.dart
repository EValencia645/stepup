import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:lottie/lottie.dart';
import '../models/ModelProvider.dart';
import '04_add_steps_screen.dart';

class MyRecordsScreen extends StatefulWidget {
  const MyRecordsScreen({super.key});

  @override
  State<MyRecordsScreen> createState() => _MyRecordsScreenState();
}

class _MyRecordsScreenState extends State<MyRecordsScreen> {
  List<StepRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  /// Returns the user's email address as their display name.
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

  Future<void> _loadRecords() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final currentUserName = await _getDisplayName();

      final request = ModelQueries.list(StepRecord.classType, limit: 1000);
      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        debugPrint('>>> MY RECORDS ERRORS: ${response.errors}');
      }

      final all = response.data?.items.whereType<StepRecord>().toList() ?? [];

      // Filter to only this user's records, newest first
      final mine = all
          .where((r) => r.userName == currentUserName)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _records = mine;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('>>> MY RECORDS LOAD ERROR: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Opens the Add/Edit screen pre-filled with [record], then reloads on save.
  Future<void> _editRecord(StepRecord record) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddStepsScreen(existingRecord: record),
      ),
    );
    if (updated == true) await _loadRecords();
  }

  /// Asks for confirmation then deletes the record from DynamoDB.
  Future<void> _deleteRecord(StepRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Delete ${record.stepCount} steps on ${record.date.format()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final request = ModelMutations.delete(record);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        debugPrint('>>> DELETE ERRORS: ${response.errors}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Delete failed: ${response.errors.first.message}'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Record deleted.'),
            ),
          );
        }
        await _loadRecords();
      }
    } catch (e) {
      debugPrint('>>> DELETE EXCEPTION: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Records'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), // true = may have changed
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/walking.json',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const Text(
                        'No records yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Add your first steps from the Dashboard.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecords,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    itemCount: _records.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.directions_walk),
                          ),
                          title: Text(
                            '${record.stepCount} steps',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(record.date.format()),
                              if (record.notes != null &&
                                  record.notes!.isNotEmpty)
                                Text(
                                  record.notes!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _editRecord(record),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteRecord(record),
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
