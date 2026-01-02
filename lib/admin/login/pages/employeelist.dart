import 'package:flutter/material.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Employee Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('5 total employees', style: TextStyle(color: Colors.grey, fontSize: 12)), // Updated count
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Table Header
          Container(
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
                Expanded(child: Text('Department', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          // LIST ITEMS (Duplicates Removed)
          Expanded(
            child: ListView(
              children: [
                _buildTableRow(context, 'EMP001', 'Hani Syakirah', 'hsyakirah@ds.com', 'IT'),
                _buildTableRow(context, 'EMP002', 'Alice Wong', 'awong@ds.com', 'IT'),
                _buildTableRow(context, 'EMP003', 'Husna Aqilah', 'haqilah@ds.com', 'Marketing'),
                _buildTableRow(context, 'EMP004', 'Amir Amzah', 'aamzah@ds.com', 'Marketing', isHighlighted: true),
                _buildTableRow(context, 'EMP005', 'Alam Ikmal', 'aikmal@ds.com', 'HR'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, String id, String name, String email, String dept, {bool isHighlighted = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Row(
        children: [
          Expanded(child: Text(id)),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(email, style: const TextStyle(decoration: TextDecoration.underline))),
          Expanded(child: Text(dept, style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(
            icon: const Icon(Icons.edit_note),
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