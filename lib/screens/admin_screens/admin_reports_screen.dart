import 'package:drophope/database_helper.dart';
import 'package:flutter/material.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = DatabaseHelper.instance.getAllReports();
  }

  void _refreshReports() {
    setState(() {
      _reportsFuture = DatabaseHelper.instance.getAllReports();
    });
  }

  void _showConfirmationDialog({
    required String action,
    required String message,
    required int reportId,
    required Function onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Confirm $action"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await onConfirm();
                _refreshReports();
              },
              child: Text(
                action,
                style: TextStyle(
                  color:
                      action == "Delete"
                          ? Colors.red
                          : action == "Resolve"
                          ? Colors.green
                          : Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reports'));
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('No reports available'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                child: ListTile(
                  title: Text("Report ID: ${report['id']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Reported By: ${report['reporter_email']}"),
                      Text("Item ID: ${report['item_id']}"),
                      Text("Reason: ${report['reason']}"),
                      Text("Status: ${report['status']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (report['status'] == "Pending") ...[
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _showConfirmationDialog(
                              action: "Resolve",
                              message:
                                  "Are you sure you want to resolve this report (ID: ${report['id']})?",
                              reportId: report['id'],
                              onConfirm: () async {
                                await DatabaseHelper.instance
                                    .updateReportStatus(
                                      report['id'],
                                      "Resolved",
                                    );
                              },
                            );
                          },
                          tooltip: 'Resolve',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _showConfirmationDialog(
                              action: "Dismiss",
                              message:
                                  "Are you sure you want to dismiss this report (ID: ${report['id']})?",
                              reportId: report['id'],
                              onConfirm: () async {
                                await DatabaseHelper.instance
                                    .updateReportStatus(
                                      report['id'],
                                      "Dismissed",
                                    );
                              },
                            );
                          },
                          tooltip: 'Dismiss',
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () {
                          _showConfirmationDialog(
                            action: "Delete",
                            message:
                                "Are you sure you want to delete this report (ID: ${report['id']})? This action cannot be undone.",
                            reportId: report['id'],
                            onConfirm: () async {
                              await DatabaseHelper.instance.deleteReport(
                                report['id'],
                              );
                            },
                          );
                        },
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
