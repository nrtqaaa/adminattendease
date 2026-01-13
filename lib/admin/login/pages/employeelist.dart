import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editemployee.dart';

class EmployeeList extends StatelessWidget {
  const EmployeeList({super.key});

  // --- LOGIC: Add Employee ---
  Future<void> _addEmployee(BuildContext context, String name, String email, String dept, String empID) async {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'name': name,
        'email': email,
        'department': dept,
        'employeeId': empID, // FIXED: Matches DB lowercase 'd'
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'staff',
      });
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Employee added successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error adding employee: $e");
    }
  }

  // --- LOGIC: Delete Employee ---
  void _confirmDelete(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Employee"),
        content: Text("Are you sure you want to remove $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(docId).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- UI: Add Employee Dialog ---
  void _showAddEmployeeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final deptController = TextEditingController();
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Employee"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: "Employee ID")),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: deptController, decoration: const InputDecoration(labelText: "Department")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => _addEmployee(context, nameController.text, emailController.text, deptController.text, idController.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1D4D), foregroundColor: Colors.white),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0B1D4D),
        onPressed: () => _showAddEmployeeDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Employee Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('$count total employees', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                );
              }
            ),
            const SizedBox(height: 24),
            _buildTableHeader(),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text("Error loading data"));
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text("No employees found."));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      
                      return _buildTableRow(
                        context, 
                        data['employeeId'] ?? 'N/A', // FIXED: Matches image_2dbeab.png
                        data['name'] ?? 'N/A', 
                        data['email'] ?? 'N/A', 
                        data['department'] ?? 'N/A', // Matches DB key
                        docs[index].id,
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

  // --- UI TABLE HELPERS ---
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFA6BDCC), borderRadius: BorderRadius.circular(8)),
      child: Row( // Removed 'const' because of the dynamic alignment
        children: [
          const Expanded(child: Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const Expanded(child: Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const Expanded(flex: 2, child: Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const Expanded(child: Text('Department', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          // FIXED: textAlign moved outside of TextStyle
          const Text(
            'Action', 
            textAlign: TextAlign.center, 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, String empID, String name, String email, String dept, String docId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4)], // Fixed withAlpha for modern Flutter
      ),
      child: Row(
        children: [
          Expanded(child: Text(empID, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(email, style: const TextStyle(color: Colors.blue))),
          Expanded(child: Text(dept)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note, color: Color(0xFF0B1D4D)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditEmployeePage(id: docId, name: name, email: email, department: dept))),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, docId, name),
              ),
            ],
          ),
        ],
      ),
    );
  }
}