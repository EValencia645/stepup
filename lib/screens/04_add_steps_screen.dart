import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ModelProvider.dart';

class AddStepsScreen extends StatefulWidget {
  /// When provided, the screen operates in edit mode for this record.
  final StepRecord? existingRecord;

  const AddStepsScreen({super.key, this.existingRecord});

  @override
  State<AddStepsScreen> createState() => _AddStepsScreenState();
}

class _AddStepsScreenState extends State<AddStepsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  bool get _isEditing => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields when editing an existing record
    if (_isEditing) {
      _stepsController.text = widget.existingRecord!.stepCount.toString();
      _notesController.text = widget.existingRecord!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _notesController.dispose();
    super.dispose();
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
    // Fallback to Cognito username
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user.username;
    } catch (e) {
      return 'User';
    }
  }

  Future<void> _saveSteps() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final stepCount = int.parse(_stepsController.text.trim());
      final notesText = _notesController.text.trim();

      if (_isEditing) {
        // UPDATE existing record — preserve id, userName, date
        final updated = widget.existingRecord!.copyWith(
          stepCount: stepCount,
          notes: notesText.isNotEmpty ? notesText : null,
        );

        final request = ModelMutations.update(updated);
        final response = await Amplify.API.mutate(request: request).response;

        if (response.hasErrors) {
          debugPrint('>>> UPDATE ERRORS: ${response.errors}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('Error: ${response.errors.first.message}'),
              ),
            );
          }
        } else {
          debugPrint('>>> UPDATE SUCCESS: ${response.data}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Record updated successfully!'),
              ),
            );
            // Return true to signal the caller to reload
            Navigator.pop(context, true);
          }
        }
      } else {
        // CREATE new record
        final currentUserName = await _getDisplayName();

        final newRecord = StepRecord(
          userName: currentUserName,
          stepCount: stepCount,
          date: TemporalDate.now(),
          notes: notesText.isNotEmpty ? notesText : null,
        );

        final request = ModelMutations.create(newRecord);
        final response = await Amplify.API.mutate(request: request).response;

        if (response.hasErrors) {
          debugPrint('>>> GRAPHQL ERRORS: ${response.errors}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('Error: ${response.errors.first.message}'),
              ),
            );
          }
        } else {
          debugPrint('>>> MUTATION SUCCESS: ${response.data}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Steps saved successfully!'),
              ),
            );
            // Return the step count so the dashboard can update its total
            Navigator.pop(context, stepCount);
          }
        }
      }
    } catch (e) {
      debugPrint('>>> EXCEPTION: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Record' : 'Add Steps'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Show the original date when editing (read-only context)
              if (_isEditing) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Date: ${widget.existingRecord!.date.format()}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _stepsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Steps',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_walk),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter step count';
                  }
                  if (int.tryParse(val.trim()) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveSteps,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'Save Changes' : 'Save Steps',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
