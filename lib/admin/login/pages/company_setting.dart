import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanySettingsPage extends StatefulWidget {
  const CompanySettingsPage({super.key});

  @override
  State<CompanySettingsPage> createState() => _CompanySettingsPageState();
}

class _CompanySettingsPageState extends State<CompanySettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- DATABASE LOGIC: Update Data ---
  Future<void> _updateSetting(String collection, String docId, String field, dynamic newValue) async {
    try {
      await _firestore.collection(collection).doc(docId).update({field: newValue});
    } catch (e) {
      debugPrint("Error updating $collection: $e");
    }
  }

  // --- UI LOGIC: Edit Dialog ---
  void _showEditDialog(String collection, String docId, String currentName, String field) {
    TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: "Enter new $field")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _updateSetting(collection, docId, field, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Company Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0B1D4D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Holiday Settings"),
            _buildHolidayTable(),
            const SizedBox(height: 40),
            _buildSectionTitle("Leave Types & Policies"),
            _buildLeaveTable(),
          ],
        ),
      ),
    );
  }

  // --- HOLIDAY TABLE (Live from Firebase) ---
  Widget _buildHolidayTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('settings_holidays').orderBy('date').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        var docs = snapshot.data!.docs;

        return _tableContainer(
          headers: ["Holiday Name", "Date", "Type", "Action"],
          rows: docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return _buildDataRow([
              Text(data['name'] ?? ''),
              Text(data['date'] ?? ''),
              Text(data['type'] ?? ''),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditDialog('settings_holidays', doc.id, data['name'], 'name'),
              ),
            ]);
          }).toList(),
        );
      },
    );
  }

  // --- LEAVE TABLE (Live from Firebase) ---
  Widget _buildLeaveTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('settings_leaves').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        var docs = snapshot.data!.docs;

        return _tableContainer(
          headers: ["Leave Name", "Paid", "Days/Year", "Carry Forward"],
          rows: docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return _buildDataRow([
              Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              _booleanIcon(data['isPaid'] ?? false),
              Text(data['daysPerYear']?.toString() ?? '0'),
              _booleanIcon(data['carryForward'] ?? false),
            ]);
          }).toList(),
        );
      },
    );
  }

  // --- REUSABLE UI HELPERS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B1D4D))),
    );
  }

  Widget _tableContainer({required List<String> headers, required List<Widget> rows}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFFA7BBC7), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: headers.map((h) => Expanded(child: Text(h, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))).toList(),
            ),
          ),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildDataRow(List<Widget> cells) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(children: cells.map((c) => Expanded(child: c)).toList()),
    );
  }

  Widget _booleanIcon(bool val) {
    return Icon(val ? Icons.check_circle : Icons.cancel, color: val ? Colors.green : Colors.red, size: 20);
  }
}