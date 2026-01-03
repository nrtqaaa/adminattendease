import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveDetailsPage extends StatelessWidget {
  final String requestId; // Added to identify the specific document
  final String employeeDocId; // Added to find the employee in the database
  final String name, id, department, position, email, phone;
  final String leaveType, startDate, endDate, totalDays, reason, status;

  const LeaveDetailsPage({
    super.key,
    required this.requestId,
    required this.employeeDocId,
    required this.name,
    required this.id,
    required this.department,
    required this.position,
    required this.email,
    required this.phone,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.status = "Pending",
  });

  // --- LOGIC: Process Approval ---
  Future<void> _processLeave(BuildContext context, String newStatus) async {
    final firestore = FirebaseFirestore.instance;
    final double daysToDeduct = double.tryParse(totalDays) ?? 0;

    try {
      // 1. Update the Leave Request Status
      await firestore.collection('leaveRequests').doc(requestId).update({
        'status': newStatus,
        'processedAt': FieldValue.serverTimestamp(),
      });

      // 2. If Approved, deduct from the correct balance field
      if (newStatus == "Approved") {
        String balanceField = _getBalanceField(leaveType);
        await firestore.collection('employees').doc(employeeDocId).update({
          balanceField: FieldValue.increment(-daysToDeduct),
        });
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request $newStatus for $name")),
        );
      }
    } catch (e) {
      debugPrint("Error processing leave: $e");
    }
  }

  String _getBalanceField(String type) {
    if (type.contains("Annual")) return 'alBal';
    if (type.contains("Sick")) return 'slBal';
    return 'elBal'; // Default to Emergency
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            _buildHeader(context),

            // SCROLLABLE CONTENT
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildEmployeeInfoSection(),
                    const SizedBox(height: 20),
                    _buildLeaveDetailsSection(),
                  ],
                ),
              ),
            ),

            // FOOTER ACTIONS
            _buildFooterActions(context),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Leave Request Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Reviewing employee submission", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Employee Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              _avatarPlaceholder(),
              const SizedBox(width: 20),
              Expanded(
                child: Wrap(
                  spacing: 20, runSpacing: 10,
                  children: [
                    _infoColumn("Employee Name", name),
                    _infoColumn("Employee ID", id),
                    _infoColumn("Department", department),
                    _infoColumn("Position", position),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Leave Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildInputBox("Leave Type", leaveType)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatusBox("Status", status)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInputBox("Start Date", startDate)),
              const SizedBox(width: 20),
              Expanded(child: _buildInputBox("End Date", endDate)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputBox("Total Days", "$totalDays Days"),
          const SizedBox(height: 16),
          const Text("Reasons", style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Text(reason, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    bool isPending = status == "Pending";
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isPending) ...[
            _actionButton(context, "Reject", Icons.close, Colors.red[50]!, () => _processLeave(context, "Rejected")),
            const SizedBox(width: 12),
            _actionButton(context, "Approve", Icons.check, Colors.green[50]!, () => _processLeave(context, "Approved")),
          ] else
            const Text("This request has already been processed.", style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // --- REUSABLE UI WIDGETS ---

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: Colors.black),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.person, size: 40, color: Colors.grey),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildInputBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildStatusBox(String label, String value) {
    Color statusColor = value == "Pending" ? const Color(0xFFFFF59D) : (value == "Approved" ? Colors.green[100]! : Colors.red[100]!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
          child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}