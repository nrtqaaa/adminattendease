import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PayslipManagementPage extends StatefulWidget {
  const PayslipManagementPage({super.key});

  @override
  State<PayslipManagementPage> createState() => _PayslipManagementPageState();
}

class _PayslipManagementPageState extends State<PayslipManagementPage> {
  String _searchQuery = "";

  // 1. ADD EMPLOYEE LOGIC: Manually add a payroll record
  void _showAddEmployeeDialog() {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final monthCtrl = TextEditingController();
    final basicCtrl = TextEditingController();
    final netCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Employee Payroll"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPopupField("Full Name", nameCtrl),
              _buildPopupField("Employee ID", idCtrl),
              _buildPopupField("Department", deptCtrl),
              _buildPopupField("Month (e.g., Jan 2026)", monthCtrl),
              _buildPopupField("Basic Salary (RM)", basicCtrl, isNumber: true),
              _buildPopupField("Net Pay (RM)", netCtrl, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1D4D)),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && idCtrl.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('payroll').add({
                  'name': nameCtrl.text,
                  'employeeId': idCtrl.text,
                  'dept': deptCtrl.text,
                  'month': monthCtrl.text,
                  'basic': double.tryParse(basicCtrl.text) ?? 0.0,
                  'net': double.tryParse(netCtrl.text) ?? 0.0,
                  'status': 'PENDING',
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("ADD TO LIST", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 2. UPDATE LOGIC: Update existing Status or Salary
  Future<void> _updatePayroll(String docId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('payroll').doc(docId).update(data);
    } catch (e) {
      debugPrint("Update failed: $e");
    }
  }

  void _showEditSalaryDialog(String docId, Map<String, dynamic> data) {
    final basicCtrl = TextEditingController(text: (data['basic'] ?? 0).toString());
    final netCtrl = TextEditingController(text: (data['net'] ?? 0).toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Salary: ${data['name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPopupField("Basic Salary (RM)", basicCtrl, isNumber: true),
            _buildPopupField("Net Pay (RM)", netCtrl, isNumber: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              _updatePayroll(docId, {
                'basic': double.tryParse(basicCtrl.text) ?? 0.0,
                'net': double.tryParse(netCtrl.text) ?? 0.0,
              });
              Navigator.pop(context);
            },
            child: const Text("UPDATE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The Floating Action Button for adding employees
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: const Color(0xFF0B1D4D),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("ADD EMPLOYEE", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: "Search by name...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('payroll').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final docs = snapshot.data!.docs.where((doc) {
                    return doc['name'].toString().toLowerCase().contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      String docId = docs[index].id;
                      bool isPaid = data['status'] == "PAID";

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("ID: ${data['employeeId']} | Month: ${data['month']}\nBasic: RM${data['basic']} | Net: RM${data['net']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Toggle PENDING/PAID
                              ActionChip(
                                label: Text(data['status'] ?? "PENDING"),
                                backgroundColor: isPaid ? Colors.green[100] : Colors.orange[100],
                                onPressed: () => _updatePayroll(docId, {'status': isPaid ? "PENDING" : "PAID"}),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditSalaryDialog(docId, data),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupField(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}