import 'package:flutter/material.dart';

class PayslipManagementPage extends StatefulWidget {
  const PayslipManagementPage({super.key});

  @override
  State<PayslipManagementPage> createState() => _PayslipManagementPageState();
}

class _PayslipManagementPageState extends State<PayslipManagementPage> {
  // 1. Master list of data
  final List<Map<String, String>> _allPayrollData = [
    {"name": "Hani Syakirah", "id": "EMP001", "dept": "IT", "month": "November", "basic": "RM 5,000", "net": "RM 5,000", "status": "PENDING"},
    {"name": "Alice Wong", "id": "EMP002", "dept": "IT", "month": "November", "basic": "RM 5,000", "net": "RM 5,000", "status": "PAID"},
    {"name": "Husna Aqilah", "id": "EMP003", "dept": "Marketing", "month": "November", "basic": "RM 5,000", "net": "RM 5,000", "status": "PAID"},
    {"name": "Amir Amzah", "id": "EMP004", "dept": "Marketing", "month": "November", "basic": "RM 5,000", "net": "RM 5,000", "status": "PAID"},
    {"name": "Alam Ikmal", "id": "EMP005", "dept": "HR", "month": "November", "basic": "RM 5,000", "net": "RM 5,000", "status": "PAID"},
  ];

  List<Map<String, String>> _filteredData = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(_allPayrollData);
  }

  // Logic: Search Filter
  void _runFilter(String enteredKeyword) {
    setState(() {
      if (enteredKeyword.isEmpty) {
        _filteredData = List.from(_allPayrollData);
      } else {
        _filteredData = _allPayrollData
            .where((user) =>
                user["name"]!.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
                user["id"]!.toLowerCase().contains(enteredKeyword.toLowerCase()))
            .toList();
      }
    });
  }

  // Logic: Update the Status in the master list
  void _handleStatusChange(String id, String newStatus) {
    setState(() {
      // Update master list
      final index = _allPayrollData.indexWhere((item) => item["id"] == id);
      if (index != -1) {
        _allPayrollData[index]["status"] = newStatus;
      }
      // Re-apply filter to keep the view consistent
      _runFilter(_searchController.text);
    });
  }

  // UI: Action Dialog
  void _showEditAction(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Status: ${item['name']}"),
          content: Text("Change payment status for ${item['month']}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                _handleStatusChange(item["id"]!, "PENDING");
                Navigator.pop(context);
              },
              child: const Text("SET PENDING", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                _handleStatusChange(item["id"]!, "PAID");
                Navigator.pop(context);
              },
              child: const Text("SET PAID", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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

          // Search Bar
          _buildSearchInput("Search by name or employee ID"),
          const SizedBox(height: 24),

          // Header
          _buildTableHeader(["Employee", "Department", "Month", "Basic", "Net", "Status", "Action"]),

          // Table Body
          Expanded(
            child: _filteredData.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) => _buildPayrollRow(_filteredData[index]),
                  )
                : const Center(child: Text("No results found")),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(String hint) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(4)),
      child: TextField(
        controller: _searchController,
        onChanged: _runFilter,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
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

  Widget _buildPayrollRow(Map<String, String> item) {
    bool isPaid = item["status"] == "PAID";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(item["id"]!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(child: Text(item["dept"]!)),
          Expanded(child: Text(item["month"]!)),
          Expanded(child: Text(item["basic"]!)),
          Expanded(child: Text(item["net"]!)),
          Expanded(
            child: Text(
              item["status"]!,
              style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              onPressed: () => _showEditAction(item), // Functionality starts here
            ),
          ),
        ],
      ),
    );
  }
}