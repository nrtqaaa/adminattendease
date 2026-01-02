import 'package:flutter/material.dart';

class LeaveBalancePage extends StatefulWidget {
  const LeaveBalancePage({super.key});

  @override
  State<LeaveBalancePage> createState() => _LeaveBalancePageState();
}

class _LeaveBalancePageState extends State<LeaveBalancePage> {
  // 1. DATA: Master list of employees
  final List<Map<String, dynamic>> _allEmployees = [
    {"name": "Hani Syakirah", "id": "EMP001", "dept": "IT", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Alice Wong", "id": "EMP002", "dept": "IT", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Husna Aqilah", "id": "EMP003", "dept": "Marketing", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Amir Amzah", "id": "EMP004", "dept": "Marketing", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Alam Ikmal", "id": "EMP005", "dept": "HR", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Amir Amzah", "id": "EMP006", "dept": "Sales", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Alam Ikmal", "id": "EMP007", "dept": "Sales", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
  ];

  List<Map<String, dynamic>> _filteredEmployees = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredEmployees = _allEmployees;
  }

  // 2. LOGIC: Filter
  void _runFilter(String enteredKeyword) {
    setState(() {
      if (enteredKeyword.isEmpty) {
        _filteredEmployees = _allEmployees;
      } else {
        _filteredEmployees = _allEmployees
            .where((user) =>
                user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
                user["id"].toLowerCase().contains(enteredKeyword.toLowerCase()))
            .toList();
      }
    });
  }

  // 3. LOGIC: Update Data
  void _updateLeaveData(String id, int al, int sl, int el) {
    setState(() {
      final index = _allEmployees.indexWhere((emp) => emp["id"] == id);
      if (index != -1) {
        _allEmployees[index]["alBal"] = al;
        _allEmployees[index]["slBal"] = sl;
        _allEmployees[index]["elBal"] = el;
      }
    });
  }

  // 4. UI: Edit Dialog
  void _showEditDialog(Map<String, dynamic> emp) {
    final alCtrl = TextEditingController(text: emp["alBal"].toString());
    final slCtrl = TextEditingController(text: emp["slBal"].toString());
    final elCtrl = TextEditingController(text: emp["elBal"].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Balance: ${emp['name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField("Annual Leave", alCtrl),
            _buildDialogTextField("Sick Leave", slCtrl),
            _buildDialogTextField("Emergency Leave", elCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1D4D)),
            onPressed: () {
              _updateLeaveData(
                emp["id"],
                int.tryParse(alCtrl.text) ?? emp["alBal"],
                int.tryParse(slCtrl.text) ?? emp["slBal"],
                int.tryParse(elCtrl.text) ?? emp["elBal"],
              );
              Navigator.pop(context);
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header & Search Section
          _buildHeaderSection(),
          
          // Table Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildTableHeader(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _filteredEmployees.isNotEmpty
                        ? ListView.builder(
                            itemCount: _filteredEmployees.length,
                            itemBuilder: (context, index) => _buildBalanceRow(_filteredEmployees[index]),
                          )
                        : const Center(child: Text("No employees found")),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          const Text("Welcome back, Admin", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 20),
          Container(
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black12)),
            child: TextField(
              controller: _searchController,
              onChanged: _runFilter,
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
      child: Row(
        children: const [
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

  Widget _buildBalanceRow(Map<String, dynamic> emp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF0F4F7), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(emp["name"], style: const TextStyle(fontWeight: FontWeight.bold)), Text(emp["id"], style: const TextStyle(color: Colors.grey, fontSize: 12))])),
          Expanded(flex: 1, child: Text(emp["dept"], style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: _buildLeaveCell(emp["alBal"], emp["alTotal"])),
          Expanded(flex: 1, child: _buildLeaveCell(emp["slBal"], emp["slTotal"])),
          Expanded(flex: 1, child: _buildLeaveCell(emp["elBal"], emp["elTotal"])),
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.blue, size: 28),
            onPressed: () => _showEditDialog(emp),
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
}