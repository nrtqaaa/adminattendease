import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveBalancePage extends StatefulWidget {
  const LeaveBalancePage({super.key});

  @override
  State<LeaveBalancePage> createState() => _LeaveBalancePageState();
}

class _LeaveBalancePageState extends State<LeaveBalancePage> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // 1. DATABASE LOGIC: Update Firestore
  Future<void> _updateFirebaseBalance(String docId, int al, int sl, int el) async {
    try {
      await FirebaseFirestore.instance.collection('employees').doc(docId).update({
        'alBal': al,
        'slBal': sl,
        'elBal': el,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Balance updated successfully")),
        );
      }
    } catch (e) {
      debugPrint("Update failed: $e");
    }
  }

  // 2. UI: Edit Dialog
  void _showEditDialog(String docId, Map<String, dynamic> emp) {
    final alCtrl = TextEditingController(text: (emp["alBal"] ?? 0).toString());
    final slCtrl = TextEditingController(text: (emp["slBal"] ?? 0).toString());
    final elCtrl = TextEditingController(text: (emp["elBal"] ?? 0).toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Balance: ${emp['name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField("Annual Leave Balance", alCtrl),
            _buildDialogTextField("Sick Leave Balance", slCtrl),
            _buildDialogTextField("Emergency Leave Balance", elCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1D4D)),
            onPressed: () {
              _updateFirebaseBalance(
                docId,
                int.tryParse(alCtrl.text) ?? 0,
                int.tryParse(slCtrl.text) ?? 0,
                int.tryParse(elCtrl.text) ?? 0,
              );
              Navigator.pop(context);
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeaderSection(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildTableHeader(),
                  const SizedBox(height: 10),
                  Expanded(
                    // 3. LIVE STREAM: Fetching from Firestore
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                        // Filter logic for search
                        var docs = snapshot.data!.docs.where((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          String name = data['name']?.toLowerCase() ?? "";
                          String id = doc.id.toLowerCase();
                          return name.contains(_searchQuery.toLowerCase()) || id.contains(_searchQuery.toLowerCase());
                        }).toList();

                        if (docs.isEmpty) return const Center(child: Text("No employees found"));

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            var empData = docs[index].data() as Map<String, dynamic>;
                            return _buildBalanceRow(docs[index].id, empData);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS (SAME AS YOURS WITH MINOR TWEAKS) ---

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        border: Border(bottom: BorderSide(color: Colors.blue, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Leave Balance Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Live Employee Quota Tracking", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 20),
          Container(
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black12)),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: "Search by name or employee ID",
                prefixIcon: Icon(Icons.search, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFA6BDCC), borderRadius: BorderRadius.circular(8)),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text("Employee", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("Dept", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("Annual", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("Sick", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("Emergency", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Text("Action", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(String docId, Map<String, dynamic> emp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF0F4F7), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(emp["name"] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)), Text(docId, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
          Expanded(flex: 1, child: Text(emp["department"] ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: _buildLeaveCell(emp["alBal"] ?? 0, emp["alTotal"] ?? 22)),
          Expanded(flex: 1, child: _buildLeaveCell(emp["slBal"] ?? 0, emp["slTotal"] ?? 14)),
          Expanded(flex: 1, child: _buildLeaveCell(emp["elBal"] ?? 0, emp["elTotal"] ?? 5)),
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.blue, size: 28),
            onPressed: () => _showEditDialog(docId, emp),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCell(int balance, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$balance", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text("OF $total", style: const TextStyle(fontSize: 8, color: Colors.grey)),
        Text("${total - balance} used", style: const TextStyle(fontSize: 8, color: Colors.redAccent)),
      ],
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}