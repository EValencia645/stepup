import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ModelProvider.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  bool _isLoading = true;
  String _currentUser = '';
  List<Map<String, dynamic>> _memberStats = []; // per-member step totals
  int _totalTeamSteps = 0;
  double _avgStepsPerMember = 0;
  int _memberCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
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

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _currentUser = await _getDisplayName();
      final team = widget.team;

      // 1. Get all members of this team
      final memberRequest =
          ModelQueries.list(TeamMember.classType, limit: 1000);
      final memberResponse =
          await Amplify.API.query(request: memberRequest).response;
      final members = memberResponse.data?.items
              .whereType<TeamMember>()
              .where((m) => m.teamId == team.id)
              .toList() ??
          [];
      final memberNames = members.map((m) => m.userName).toSet();

      // 2. Get all StepRecords that fall within the challenge date range
      final stepRequest =
          ModelQueries.list(StepRecord.classType, limit: 1000);
      final stepResponse =
          await Amplify.API.query(request: stepRequest).response;
      final allRecords = stepResponse.data?.items
              .whereType<StepRecord>()
              .toList() ??
          [];

      // Filter: only records by team members, within start–end dates
      final startDate = DateTime(
        team.startDate.getDateTime().year,
        team.startDate.getDateTime().month,
        team.startDate.getDateTime().day,
      );
      final endDate = DateTime(
        team.endDate.getDateTime().year,
        team.endDate.getDateTime().month,
        team.endDate.getDateTime().day,
        23, 59, 59,
      );

      final relevantRecords = allRecords.where((r) {
        if (!memberNames.contains(r.userName)) return false;
        final d = r.date.getDateTime();
        return !d.isBefore(startDate) && !d.isAfter(endDate);
      }).toList();

      // 3. Aggregate steps per member
      final Map<String, int> stepsByMember = {};
      for (final name in memberNames) {
        stepsByMember[name] = 0;
      }
      for (final record in relevantRecords) {
        stepsByMember[record.userName] =
            (stepsByMember[record.userName] ?? 0) + record.stepCount;
      }

      // 4. Sort by steps descending
      final sorted = stepsByMember.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final total = sorted.fold(0, (sum, e) => sum + e.value);
      final avg = memberNames.isEmpty ? 0.0 : total / memberNames.length;

      if (mounted) {
        setState(() {
          _memberStats = sorted
              .asMap()
              .entries
              .map((entry) => {
                    'rank': entry.key + 1,
                    'name': entry.value.key,
                    'steps': entry.value.value,
                    'isCurrentUser': entry.value.key == _currentUser,
                  })
              .toList();
          _totalTeamSteps = total;
          _avgStepsPerMember = avg;
          _memberCount = memberNames.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('>>> TEAM DETAIL LOAD ERROR: $e');
      if (mounted) setState(() => _isLoading = false);
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

  /// Progress toward goal (0.0 – 1.0), or null if no goal set.
  double? get _goalProgress {
    final goal = widget.team.goalSteps;
    if (goal == null || goal == 0) return null;
    return (_totalTeamSteps / goal).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final progress = _goalProgress;

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Challenge info ──────────────────────────────────
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                '${team.startDate.format()}  →  ${team.endDate.format()}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.group,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                '$_memberCount member${_memberCount == 1 ? '' : 's'}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          if (team.code == team.code &&
                              team.createdBy == _currentUser) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.vpn_key,
                                    size: 18, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  'Join code: ${team.code}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Stats side by side ───────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total Steps',
                          value: _totalTeamSteps.toString(),
                          icon: Icons.directions_walk,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Avg per Member',
                          value: _avgStepsPerMember.toStringAsFixed(0),
                          icon: Icons.bar_chart,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  // ── Goal progress bar (if goal was set) ──────────────
                  if (progress != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Team Goal',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  '${(progress * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: progress >= 1.0
                                        ? Colors.green
                                        : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 12,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress >= 1.0
                                      ? Colors.green
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$_totalTeamSteps / ${team.goalSteps} steps',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text(
                    'Leaderboard',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // ── Per-member leaderboard ───────────────────────────
                  if (_memberStats.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No steps logged yet for this challenge period.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...(_memberStats.map((entry) {
                      final rank = entry['rank'] as int;
                      final isCurrent = entry['isCurrentUser'] as bool;
                      return Card(
                        elevation: isCurrent ? 3 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: isCurrent
                              ? BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  width: 1.5)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: _getBadgeColor(rank),
                            foregroundColor: Colors.white,
                            child: Text('#$rank',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(
                            isCurrent ? 'You' : entry['name'] as String,
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.directions_walk,
                                  size: 20, color: Colors.blueAccent),
                              const SizedBox(width: 6),
                              Text(
                                '${entry['steps']} steps',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    })),
                ],
              ),
            ),
    );
  }
}

/// Small stat card widget used for Total Steps / Avg per Member.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
