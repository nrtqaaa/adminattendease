import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PayslipManagementPage extends StatefulWidget {
  const PayslipManagementPage({super.key});

  @override
  State<PayslipManagementPage> createState() => _PayslipManagementPageState();
}

class _PayslipManagementPageState extends State<PayslipManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Logic: Update Status in Firestore
  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('payroll')
          .doc(docId)
          .update({'status': newStatus});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status updated to $newStatus")),
        );
      }
    } catch (e) {
      debugPrint("Update failed: $e");
    }
  }

  // UI: Action Dialog
  void _showEditAction(String docId, String name, String month) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Status: $name"),
        content: Text("Change payment status for $month?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              _updateStatus(docId, "PENDING");
              Navigator.pop(context);
            },
            child: const Text("SET PENDING", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              _updateStatus(docId, "PAID");
              Navigator.pop(context);
            },
            child: const Text("SET PAID", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Payslip Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Welcome back, Admin", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 24),

          _buildSearchInput(),
          const SizedBox(height: 24),

          _buildTableHeader(["Employee", "Department", "Month", "Basic", "Net", "Status", "Action"]),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('payroll').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading data"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                // Filter logic on the client side for search
                final docs = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  final id = doc['employeeId'].toString().toLowerCase();
                  return name.contains(_searchQuery) || id.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) return const Center(child: Text("No payroll records found"));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) => _buildPayrollRow(docs[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(4)),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
        decoration: const InputDecoration(
          hintText: "Search by name or employee ID",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildTableHeader(List<String> labels) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFA7BBC7),
      child: Row(
        children: labels.map((l) => Expanded(child: Text(l, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))).toList(),
      ),
    );
  }

  Widget _buildPayrollRow(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    bool isPaid = data["status"] == "PAID";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(data["employeeId"] ?? "", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(child: Text(data["dept"] ?? "")),
          Expanded(child: Text(data["month"] ?? "")),
          Expanded(child: Text("RM ${data["basic"]}")),
          Expanded(child: Text("RM ${data["net"]}")),
          Expanded(
            child: Text(
              data["status"] ?? "",
              style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              onPressed: () => _showEditAction(doc.id, data["name"], data["month"]),
            ),
          ),
        ],
      ),
    );
  }
}