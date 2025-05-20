import 'package:flutter/material.dart';
import 'package:drophope/screens/admin_screens/report.dart';
import 'package:drophope/database_helper.dart';

class ReportProvider extends ChangeNotifier {
  List<Report> _reports = [];

  List<Report> get reports => List.unmodifiable(_reports);

  ReportProvider() {
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reportMaps = await DatabaseHelper.instance.getAllReports();
      _reports = reportMaps.map((map) => Report.fromMap(map)).toList();
      debugPrint('ReportProvider: Loaded ${_reports.length} reports');
    } catch (e) {
      debugPrint('ReportProvider: Error loading reports: $e');
      _reports = [];
    }
    notifyListeners();
  }

  Future<void> addReport(Report report) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final id = await dbHelper.insertReport(report.toMap());
      _reports.add(report.copyWith(id: id));
      debugPrint('ReportProvider: Added report with id $id');
    } catch (e) {
      debugPrint('ReportProvider: Error adding report: $e');
    }
    notifyListeners();
  }

  Future<void> updateReportStatus(int id, String newStatus) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.updateReportStatus(id, newStatus);
      final report = _reports.firstWhere((r) => r.id == id);
      report.status = newStatus;
      debugPrint('ReportProvider: Updated report $id status to $newStatus');
    } catch (e) {
      debugPrint('ReportProvider: Error updating report status: $e');
    }
    notifyListeners();
  }

  Future<void> deleteReport(int id) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.deleteReport(id);
      _reports.removeWhere((r) => r.id == id);
      debugPrint('ReportProvider: Deleted report with id $id');
    } catch (e) {
      debugPrint('ReportProvider: Error deleting report: $e');
    }
    notifyListeners();
  }
}

extension on Report {
  Report copyWith({int? id}) {
    return Report(
      id: id ?? this.id,
      reporterEmail: reporterEmail,
      itemId: itemId,
      reason: reason,
      status: status,
    );
  }
}
