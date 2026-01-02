import 'package:flutter/material.dart';

class LeaveDetailsPage extends StatelessWidget {
  // 1. Add variables to hold the specific person's data
  final String name;
  final String id;
  final String department;
  final String position;
  final String email;
  final String phone;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String totalDays;
  final String reason;
  final String status;

  const LeaveDetailsPage({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 900), // Fixed width error
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Leave Request Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Welcome back, Admin", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // SCROLLABLE CONTENT
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // SECTION A: Employee Information
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Employee Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.person, size: 40, color: Colors.grey),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Row(
                                  children: [
                                    _infoColumn("Employee Name", name), // Use variable
                                    _infoColumn("Employee ID", id),     // Use variable
                                    _infoColumn("Department", department), // Use variable
                                    _infoColumn("Position", position),   // Use variable
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const SizedBox(width: 80),
                              const Icon(Icons.email, size: 14, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(email, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 20),
                              const Icon(Icons.phone, size: 14, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(phone, style: const TextStyle(fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SECTION B: Leave Details
                    Container(
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
                          Row(
                            children: [
                              Expanded(child: _buildInputBox("Total Days", totalDays)),
                              const SizedBox(width: 20),
                              Expanded(child: _buildInputBox("Submitted Date", "01/12/2025")), // Static for now
                            ],
                          ),
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
                    ),
                  ],
                ),
              ),
            ),

            // FOOTER ACTIONS
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rejected request for $name")));
                    },
                    icon: const Icon(Icons.close, size: 16, color: Colors.black),
                    label: const Text("Reject", style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 0),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Approved request for $name")));
                    },
                    icon: const Icon(Icons.check, size: 16, color: Colors.black),
                    label: const Text("Approve", style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInputBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildStatusBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFFFF59D), borderRadius: BorderRadius.circular(20)),
          child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
        ),
      ],
    );
  }
}