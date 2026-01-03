import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportSearchPage extends StatefulWidget {
  const ReportSearchPage({super.key});
  @override
  State<ReportSearchPage> createState() => _ReportSearchPageState();
}

class _ReportSearchPageState extends State<ReportSearchPage> {
  String _selectedEmpId = "EMP001";
  String _selectedMonth = "November";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Report")),
      body: Column(
        children: [
          _buildFilterHeader(),
          Expanded(child: _buildFirebaseTable()),
        ],
      ),
    );
  }

  Widget _buildFirebaseTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .where('empId', isEqualTo: _selectedEmpId)
          .where('month', isEqualTo: _selectedMonth)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text("Date: ${data['date']}"),
              subtitle: Text("Status: ${data['remark']}"),
              trailing: Text(data['hours']),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _selectedEmpId,
            items: ["EMP001", "EMP002"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedEmpId = v!),
          ),
          const SizedBox(width: 20),
          DropdownButton<String>(
            value: _selectedMonth,
            items: ["November", "December"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedMonth = v!),
          ),
        ],
      ),
    );
  }
}