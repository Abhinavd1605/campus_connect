import 'package:campus_connect/models/issue.dart';
import 'package:campus_connect/screens/issues/report_issue_screen.dart';
import 'package:campus_connect/services/database_service.dart';
import 'package:campus_connect/utils/app_styles.dart';
import 'package:campus_connect/utils/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Tracking Board'),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: StreamBuilder<List<Issue>>(
        stream: _databaseService.getIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error:  [${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No issues reported yet.'));
          }
          final issues = snapshot.data!;
          final reported = issues.where((i) => i.status == 'Reported').toList();
          final inProgress = issues.where((i) => i.status == 'In Progress').toList();
          final resolved = issues.where((i) => i.status == 'Resolved').toList();

          // Responsive: allow horizontal scroll if needed, with fixed height
          return SizedBox(
            height: 600, // Fixed height for the board area
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildIssueColumn(
                    title: 'Reported',
                    icon: Icons.report_problem_rounded,
                    color: Colors.orangeAccent,
                    gradient: LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrangeAccent]),
                    issues: reported,
                  ),
                  _buildIssueColumn(
                    title: 'In Progress',
                    icon: Icons.autorenew,
                    color: Colors.blueAccent,
                    gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
                    issues: inProgress,
                  ),
                  _buildIssueColumn(
                    title: 'Resolved',
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                    issues: resolved,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            CustomPageRoute(
              child: const ReportIssueScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: AppStyles.primaryColor,
      ),
    );
  }

  Widget _buildIssueColumn({
    required String title,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required List<Issue> issues,
  }) {
    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: color.withOpacity(0.85),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    issues.length.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: issues.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No issues',
                        style: AppStyles.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: issues.length,
                    itemBuilder: (context, index) {
                      return _buildIssueCard(issues[index], color, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(Issue issue, Color color, int index) {
    IconData priorityIcon;
    Color priorityColor;
    switch (issue.priority.toLowerCase()) {
      case 'high':
        priorityIcon = Icons.priority_high;
        priorityColor = Colors.redAccent;
        break;
      case 'medium':
        priorityIcon = Icons.trending_up;
        priorityColor = Colors.amber;
        break;
      default:
        priorityIcon = Icons.low_priority;
        priorityColor = Colors.greenAccent;
    }
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Icon(priorityIcon, color: priorityColor, size: 28),
                title: Text(
                  issue.description,
                  style: AppStyles.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppStyles.textDark),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            issue.location,
                            style: AppStyles.textTheme.bodySmall?.copyWith(color: AppStyles.textMedium),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(issue.reportedDate.toDate()),
                          style: AppStyles.textTheme.bodySmall?.copyWith(color: AppStyles.textLight),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    issue.priority,
                    style: AppStyles.textTheme.labelMedium?.copyWith(color: priorityColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 