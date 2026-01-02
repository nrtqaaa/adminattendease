import 'package:flutter/material.dart';

class ClaimManagementPage extends StatelessWidget {
  const ClaimManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Claim Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Welcome back, Admin", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 24),

          // FILTERS
          _buildLongSearchInput("Search by name or employee ID"),
          const SizedBox(height: 10),
          _buildLongSearchInput(""),
          const SizedBox(height: 24),

          // MANAGEMENT TABLE
          _buildManagementHeader(["Employeee", "Type", "Description", "Amount", "Date", "Status", "Action"]),
          Expanded(
            child: ListView(
              children: [
                _buildManagementRow("Hani Syakirah", "EMP001", "Travel", "Client Meeting", "RM 450", "1/11/2025", "Pending", isPending: true),
                _buildManagementRow("Hani Syakirah", "EMP001", "Medical", "Medical Checkup", "RM 500", "14/11/2025", "Approved"),
                _buildManagementRow("Hani Syakirah", "EMP001", "Office supplies", "Ergonomic Keyboard", "RM 100", "23/11/2025", "Rejected"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLongSearchInput(String hint) {
    return Container(
      width: double.infinity,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        border: Border.all(color: Colors.black26),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(hint, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13)),
      ),
    );
  }

  Widget _buildManagementHeader(List<String> labels) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Color(0xFFA7BBC7)),
      child: Row(
        children: labels.map((l) => Expanded(child: Text(l, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))).toList(),
      ),
    );
  }

  Widget _buildManagementRow(String name, String id, String type, String desc, String amount, String date, String status, {bool isPending = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(id, style: const TextStyle(fontSize: 12)),
            ],
          )),
          Expanded(child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(desc, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(date, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: isPending 
              ? Row(
                  children: [
                    _buildStatusIcon(Icons.check, Colors.green, const Color(0xFFA5D6A7)),
                    const SizedBox(width: 8),
                    _buildStatusIcon(Icons.close, Colors.red, const Color(0xFFEF9A9A)),
                  ],
                )
              : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: color)),
      child: Icon(icon, color: color, size: 16),
    );
  }
}