import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ModelProvider.dart';

class AddStepsScreen extends StatefulWidget {
  const AddStepsScreen({super.key});

  @override
  State<AddStepsScreen> createState() => _AddStepsScreenState();
}

class _AddStepsScreenState extends State<AddStepsScreen> {
  final TextEditingController _stepsController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _saveSteps() async {
  final text = _stepsController.text.trim();
  final steps = int.tryParse(text);

  if (steps == null || steps <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a valid step count.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {
    final now = DateTime.now();

    final stepRecord = StepRecord(
      stepCount: steps,
      date: TemporalDate(
        DateTime(now.year, now.month, now.day),
      ),
      notes: 'Logged via StepUp',
    );

    final request = ModelMutations.create(stepRecord);

    final response =
        await Amplify.API.mutate(request: request).response;

    if (response.hasErrors) {
      safePrint('ERRORS: ${response.errors}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.errors.first.message),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      safePrint(
        'SUCCESS! Saved record with id: ${response.data?.id}',
      );

      Navigator.pop(context, steps);
    }
  } on ApiException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.message}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Steps'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _stepsController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Enter Steps',
                  hintText: 'e.g. 5000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_walk),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveSteps,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Steps'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}