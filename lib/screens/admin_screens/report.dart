class Report {
  final int? id; // Auto-incremented by the database
  final String reporterEmail;
  final int itemId;
  final String reason;
  String status; // "Pending", "Resolved", "Dismissed"

  Report({
    this.id,
    required this.reporterEmail,
    required this.itemId,
    required this.reason,
    this.status = "Pending",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporter_email': reporterEmail,
      'item_id': itemId,
      'reason': reason,
      'status': status,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      reporterEmail: map['reporter_email'],
      itemId: map['item_id'],
      reason: map['reason'],
      status: map['status'] ?? "Pending",
    );
  }
}
