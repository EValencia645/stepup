import 'models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_api/amplify_api.dart';

import 'amplify_outputs.dart';
import 'screens/01_welcome_screen.dart';
import 'screens/03_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const StepUpApp());
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final api = AmplifyAPI(
      options: APIPluginOptions(modelProvider: ModelProvider.instance),
    );
    await Amplify.addPlugins([auth, api]);
    await Amplify.configure(amplifyConfig);
    safePrint('Successfully configured Amplify');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class StepUpApp extends StatelessWidget {
  const StepUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        builder: Authenticator.builder(),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (mounted) {
        setState(() {
          _isSignedIn = session.isSignedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSignedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Directs to Dashboard if already logged in; otherwise starts at Welcome
    return _isSignedIn ? const DashboardScreen() : const WelcomeScreen();
  }
}