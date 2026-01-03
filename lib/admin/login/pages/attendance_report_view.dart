import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  final TextEditingController _searchController = TextEditingController();
  String _employeeFilter = "EMP001"; // Default filter

  // Stream to fetch attendance from Firestore
  Stream<QuerySnapshot> _getAttendanceStream() {
    return FirebaseFirestore.instance
        .collection('attendance')
        .where('employeeId', isEqualTo: _employeeFilter) // Filter by ID
        .orderBy('timestamp', descending: true) // Newest first
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BREADCRUMB
        const Padding(
          padding: EdgeInsets.only(left: 32, top: 20),
          child: Text("Report / Attendance Report", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
        ),

        // SEARCH FILTERS
        Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Attendance Report", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              Row(
                children: [
                  _buildFilterInput("Employee's ID", (val) => _employeeFilter = val),
                  const SizedBox(width: 32),
                  _buildBlueButton("SEARCH", () => setState(() {})), // Refresh stream
                ],
              ),
            ],
          ),
        ),

        // REPORT TABLE (DYNAMIC)
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                _buildTableHeader(["Date", "Clock-in", "Clock-out", "Status"]),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getAttendanceStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) return const Center(child: Text("No records found for this ID"));

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var data = docs[index].data() as Map<String, dynamic>;
                          return _buildReportRow([
                            data['date'] ?? '-',
                            data['clockIn'] ?? '-',
                            data['clockOut'] ?? '-',
                            data['type'] ?? 'App Entry', // Shows if it's Manual or App
                          ]);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildBlueButton("GENERATE PDF", () {
                  // Logic for PDF export can go here
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ================= HELPER METHODS =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
    );
  }

  Widget _buildFilterInput(String label, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        SizedBox(
          width: 300,
          height: 40,
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlueButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0B1D4D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    );
  }

  Widget _buildTableHeader(List<String> labels) {
    return Container(
      color: const Color(0xFFA7BBC7),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: labels.map((l) => Expanded(child: Text(l, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))).toList(),
      ),
    );
  }

  Widget _buildReportRow(List<String> values) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        children: values.map((v) => Expanded(child: Text(v))).toList(),
      ),
    );
  }
}