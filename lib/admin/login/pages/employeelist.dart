import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editemployee.dart';

class EmployeeList extends StatelessWidget {
  const EmployeeList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER SECTION
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('employees').snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Employee Management', 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('$count total employees', 
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              );
            }
          ),
          const SizedBox(height: 24),
          
          // TABLE HEADER
          _buildTableHeader(),
          const SizedBox(height: 10),
          
          // LIVE DATA LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('employees')
                  .orderBy('name') 
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading data"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No employees found."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String docId = docs[index].id; 
                    
                    return _buildTableRow(
                      context, 
                      docId, 
                      data['name'] ?? 'N/A', 
                      data['email'] ?? 'N/A', 
                      data['department'] ?? 'N/A'
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER: Table Header ---
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFA6BDCC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(child: Text('Employee ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(child: Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          // FIXED: Removed the duplicate color argument and incorrect assignment
          Expanded(child: Text('Department', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- UI HELPER: Row Item ---
  Widget _buildTableRow(BuildContext context, String id, String name, String email, String dept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // FIXED: Replaced withOpacity with withValues to avoid deprecation warning
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(child: Text(id, style: const TextStyle(fontSize: 13))),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(email, style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue))),
          Expanded(child: Text(dept, style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(
            icon: const Icon(Icons.edit_note, color: Color(0xFF0B1D4D)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEmployeePage(
                    id: id,
                    name: name,
                    email: email,
                    department: dept,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}