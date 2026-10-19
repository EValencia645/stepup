import 'dart:math';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ModelProvider.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

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

  /// Generates a random 6-character alphanumeric join code.
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? now : (_startDate ?? now).add(const Duration(days: 7)),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Reset end date if it's before the new start
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please select a start and end date.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentUser = await _getDisplayName();
      final code = _generateCode();
      final goalText = _goalController.text.trim();

      final newTeam = Team(
        name: _nameController.text.trim(),
        code: code,
        createdBy: currentUser,
        startDate: TemporalDate(
            DateTime(_startDate!.year, _startDate!.month, _startDate!.day)),
        endDate: TemporalDate(
            DateTime(_endDate!.year, _endDate!.month, _endDate!.day)),
        goalSteps: goalText.isNotEmpty ? int.tryParse(goalText) : null,
      );

      final teamRequest = ModelMutations.create(newTeam);
      final teamResponse =
          await Amplify.API.mutate(request: teamRequest).response;

      if (teamResponse.hasErrors) {
        debugPrint('>>> CREATE TEAM ERRORS: ${teamResponse.errors}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error: ${teamResponse.errors.first.message}'),
            ),
          );
        }
        return;
      }

      final createdTeam = teamResponse.data!;

      // Auto-join the creator as a member
      final newMember =
          TeamMember(teamId: createdTeam.id, userName: currentUser);
      final memberRequest = ModelMutations.create(newMember);
      await Amplify.API.mutate(request: memberRequest).response;

      if (mounted) {
        // Show the join code prominently before popping
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Team Created! 🎉'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Share this code with your teammates:'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'They can join from the Teams screen using this code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('>>> CREATE TEAM EXCEPTION: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime? d) =>
      d == null ? 'Select date' : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Team'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Enter a team name' : null,
              ),
              const SizedBox(height: 16),
              // Start date picker
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text('Start Date: ${_formatDate(_startDate)}'),
                onPressed: () => _pickDate(isStart: true),
              ),
              const SizedBox(height: 12),
              // End date picker
              OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: Text('End Date: ${_formatDate(_endDate)}'),
                onPressed: () => _pickDate(isStart: false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _goalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Team Step Goal (optional)',
                  hintText: 'e.g. 100000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _createTeam,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Team',
                        style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
