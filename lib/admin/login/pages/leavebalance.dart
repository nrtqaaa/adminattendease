import 'package:flutter/material.dart';

class LeaveBalancePage extends StatefulWidget {
  const LeaveBalancePage({super.key});

  @override
  State<LeaveBalancePage> createState() => _LeaveBalancePageState();
}

class _LeaveBalancePageState extends State<LeaveBalancePage> {
  // 1. DATA: List of all employees
  final List<Map<String, dynamic>> _allEmployees = [
    {"name": "Hani Syakirah", "id": "EMP001", "dept": "IT", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Alice Wong", "id": "EMP002", "dept": "IT", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Husna Aqilah", "id": "EMP003", "dept": "Marketing", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Amir Amzah", "id": "EMP004", "dept": "Marketing", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Alam Ikmal", "id": "EMP005", "dept": "HR", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Amir Amzah", "id": "EMP006", "dept": "Sales", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
    {"name": "Alam Ikmal", "id": "EMP007", "dept": "Sales", "alBal": 14, "alTotal": 22, "slBal": 11, "slTotal": 14, "elBal": 4, "elTotal": 5},
  ];

  // 2. STATE: List used for display (starts full, gets filtered)
  List<Map<String, dynamic>> _filteredEmployees = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially, show all employees
    _filteredEmployees = _allEmployees;
  }

  // 3. LOGIC: Filter the list based on search text
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // If the search field is empty or only contains whitespace, display all users
      results = _allEmployees;
    } else {
      results = _allEmployees
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              user["id"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // Refresh the UI
    setState(() {
      _filteredEmployees = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER SECTION
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0E0),
            border: Border(bottom: BorderSide(color: Colors.blue, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Leave Balance Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Icon(Icons.search, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 4),
              const Text("Welcome back, Admin", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              const SizedBox(height: 20),
              
              // SEARCH BAR (Now Functional)
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black12),
                ),
                child: TextField(
                  controller: _searchController,
                  // Call _runFilter whenever text changes
                  onChanged: (value) => _runFilter(value),
                  decoration: const InputDecoration(
                    hintText: "Search by name or employee ID",
                    hintStyle: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    suffixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),

        // MAIN CONTENT (Table)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // TABLE HEADER
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA6BDCC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text("Employee", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text("Department", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text("Annual\nLeave", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, height: 1.1))),
                      Expanded(flex: 1, child: Text("Sick\nLeave", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, height: 1.1))),
                      Expanded(flex: 1, child: Text("Emergency\nLeave", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, height: 1.1))),
                      Text("Action", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // TABLE ROWS (Dynamic ListView)
                Expanded(
                  child: _filteredEmployees.isNotEmpty
                      ? ListView.builder(
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final emp = _filteredEmployees[index];
                            return _buildBalanceRow(
                              emp["name"],
                              emp["id"],
                              emp["dept"],
                              emp["alBal"], emp["alTotal"],
                              emp["slBal"], emp["slTotal"],
                              emp["elBal"], emp["elTotal"],
                            );
                          },
                        )
                      : const Center(
                          child: Text("No employees found", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Row Builder Helper
  Widget _buildBalanceRow(
    String name, String id, String dept, 
    int alBal, int alTotal, 
    int slBal, int slTotal, 
    int elBal, int elTotal
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(id, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(dept, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          Expanded(flex: 1, child: _buildLeaveCell(alBal, alTotal)),
          Expanded(flex: 1, child: _buildLeaveCell(slBal, slTotal)),
          Expanded(flex: 1, child: _buildLeaveCell(elBal, elTotal)),
          const Icon(Icons.edit_note_outlined, size: 28),
        ],
      ),
    );
  }

  Widget _buildLeaveCell(int balance, int total) {
    int used = total - balance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$balance", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text("OF $total DAYS", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text("$used used", style: const TextStyle(fontSize: 8, color: Colors.redAccent)),
      ],
    );
  }
}