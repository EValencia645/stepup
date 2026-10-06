import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ModelProvider.dart';

class AddStepsScreen extends StatefulWidget {
  const AddStepsScreen({super.key});

  @override
  State<AddStepsScreen> createState() => _AddStepsScreenState();
}

class _AddStepsScreenState extends State<AddStepsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _stepsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSteps() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    // 1. Retrieve the current authenticated user's Cognito username
    String currentUserName = 'User';
    try {
      final user = await Amplify.Auth.getCurrentUser();
      currentUserName = user.username;
    } catch (e) {
      debugPrint('Could not get username: $e');
    }

    final stepCount = int.parse(_stepsController.text.trim());
    final notesText = _notesController.text.trim();

    // 2. Create the record with the required userName field
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
        Navigator.pop(context, true);
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
        title: const Text('Add Steps'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _stepsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter Steps',
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
                    : const Text('Save Steps', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}