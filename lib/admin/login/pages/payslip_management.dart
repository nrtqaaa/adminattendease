import 'package:flutter/material.dart';

class PayslipManagementPage extends StatelessWidget {
  const PayslipManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Payslip Management", 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Welcome back, Admin", 
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 24),

          // SEARCH BAR SECTION
          _buildSearchInput("Search by name or employee ID"),
          const SizedBox(height: 10),
          _buildSearchInput(""),
          const SizedBox(height: 24),

          // PAYROLL TABLE
          _buildTableHeader([
            "Employeee", "Department", "Month", "Basic Salary", "Net Salary", "Status", "Action"
          ]),
          Expanded(
            child: ListView(
              children: [
                _buildPayrollRow("Hani Syakirah", "EMP001", "IT", "November", "RM 5,000", "RM 5,000", "PENDING"),
                _buildPayrollRow("Alice Wong", "EMP002", "IT", "November", "RM 5,000", "RM 5,000", "PAID"),
                _buildPayrollRow("Husna Aqilah", "EMP003", "Marketing", "November", "RM 5,000", "RM 5,000", "PAID"),
                _buildPayrollRow("Amir Amzah", "EMP004", "Marketing", "November", "RM 5,000", "RM 5,000", "PAID"),
                _buildPayrollRow("Alam Ikmal", "EMP005", "HR", "November", "RM 5,000", "RM 5,000", "PAID"),
                _buildPayrollRow("Amir Amzah", "EMP006", "Sales", "November", "RM 5,000", "RM 5,000", "PAID"),
                _buildPayrollRow("Alam Ikmal", "EMP007", "Sales", "November", "RM 5,000", "RM 5,000", "PAID"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SEARCH BAR BUILDER
  Widget _buildSearchInput(String hint) {
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
        child: Text(hint, 
          style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13)),
      ),
    );
  }

  // TABLE HEADER BUILDER
  Widget _buildTableHeader(List<String> labels) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Color(0xFFA7BBC7)),
      child: Row(
        children: labels.map((l) => Expanded(
          child: Text(l, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))
        )).toList(),
      ),
    );
  }

  // DATA ROW BUILDER
  Widget _buildPayrollRow(
    String name, String id, String dept, String month, String basic, String net, String status
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12))
      ),
      child: Row(
        children: [
          // Employee Column with ID subtext
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(id, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          Expanded(child: Text(dept, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(month, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(basic, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(net, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold))),
          // Action Icon
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.edit_note, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}