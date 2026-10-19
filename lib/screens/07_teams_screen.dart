import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:lottie/lottie.dart';
import '../models/ModelProvider.dart';
import '08_create_team_screen.dart';
import '09_team_detail_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  List<Map<String, dynamic>> _myTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
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

  Future<void> _loadTeams() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final currentUser = await _getDisplayName();

      // Fetch all TeamMember rows, filter to current user
      final memberRequest = ModelQueries.list(TeamMember.classType, limit: 1000);
      final memberResponse =
          await Amplify.API.query(request: memberRequest).response;
      final memberships = memberResponse.data?.items
              .whereType<TeamMember>()
              .where((m) => m.userName == currentUser)
              .toList() ??
          [];

      // Fetch all Teams, then match by id
      final teamRequest = ModelQueries.list(Team.classType, limit: 1000);
      final teamResponse =
          await Amplify.API.query(request: teamRequest).response;
      final allTeams =
          teamResponse.data?.items.whereType<Team>().toList() ?? [];

      final myTeamIds = memberships.map((m) => m.teamId).toSet();
      final myTeams = allTeams.where((t) => myTeamIds.contains(t.id)).toList();

      if (mounted) {
        setState(() {
          _myTeams = myTeams
              .map((t) => {
                    'team': t,
                    'isOwner': t.createdBy == currentUser,
                  })
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('>>> TEAMS LOAD ERROR: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Shows a dialog where the user enters a team code to join.
  Future<void> _joinTeamByCode() async {
    final codeController = TextEditingController();

    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join a Team'),
        content: TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Team Code',
            hintText: 'e.g. STEP42',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, codeController.text.trim().toUpperCase()),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    codeController.dispose();
    if (code == null || code.isEmpty) return;

    try {
      final currentUser = await _getDisplayName();

      // Find the team with this code
      final teamRequest = ModelQueries.list(Team.classType, limit: 1000);
      final teamResponse =
          await Amplify.API.query(request: teamRequest).response;
      final allTeams =
          teamResponse.data?.items.whereType<Team>().toList() ?? [];
      final match = allTeams.where((t) => t.code == code).toList();

      if (match.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('No team found with that code.'),
            ),
          );
        }
        return;
      }

      final team = match.first;

      // Check if already a member
      final memberRequest =
          ModelQueries.list(TeamMember.classType, limit: 1000);
      final memberResponse =
          await Amplify.API.query(request: memberRequest).response;
      final existing = memberResponse.data?.items
          .whereType<TeamMember>()
          .where((m) => m.teamId == team.id && m.userName == currentUser)
          .toList() ??
          [];

      if (existing.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are already in this team.')),
          );
        }
        return;
      }

      // Create TeamMember record
      final newMember = TeamMember(teamId: team.id, userName: currentUser);
      final createRequest = ModelMutations.create(newMember);
      final createResponse =
          await Amplify.API.mutate(request: createRequest).response;

      if (createResponse.hasErrors) {
        debugPrint('>>> JOIN TEAM ERRORS: ${createResponse.errors}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content:
                  Text('Error: ${createResponse.errors.first.message}'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Joined team "${team.name}"!'),
            ),
          );
        }
        await _loadTeams();
      }
    } catch (e) {
      debugPrint('>>> JOIN TEAM EXCEPTION: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeams,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Action buttons at the top
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.group_add),
                          label: const Text('Create Team'),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateTeamScreen(),
                              ),
                            );
                            await _loadTeams();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.login),
                          label: const Text('Join Team'),
                          onPressed: _joinTeamByCode,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Teams list
                Expanded(
                  child: _myTeams.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/animations/team.json',
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                              const Text(
                                "You're not in any teams yet.",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Create one or join with a code.',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          itemCount: _myTeams.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final entry = _myTeams[index];
                            final team = entry['team'] as Team;
                            final isOwner = entry['isOwner'] as bool;

                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: const Icon(Icons.group),
                                ),
                                title: Text(
                                  team.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${team.startDate.format()} → ${team.endDate.format()}'
                                  '${isOwner ? '  •  Code: ${team.code}' : ''}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TeamDetailScreen(team: team),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
