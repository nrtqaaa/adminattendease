import 'package:flutter/material.dart';

class DailyAttendancePage extends StatefulWidget {
  const DailyAttendancePage({super.key});

  @override
  State<DailyAttendancePage> createState() => _DailyAttendancePageState();
}

class _DailyAttendancePageState extends State<DailyAttendancePage> {
  String selectedDept = "All Departments";
  String selectedDate = "27/11/2025";

  final List<Map<String, String>> attendanceData = [
    {"id": "EMP001", "name": "Hani Syakirah", "by": "Admin", "dept": "IT", "in": "0900", "out": "1700", "status": "Present"},
    {"id": "EMP002", "name": "Alice Wong", "by": "Admin", "dept": "IT", "in": "0900", "out": "1700", "status": "On Leave"},
    {"id": "EMP005", "name": "Alam Ikmal", "by": "Admin", "dept": "HR", "in": "0900", "out": "1700", "status": "Present"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER SECTION
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // FIXED: Replaced withOpacity with withValues
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Daily Attendance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              Row(
                children: [
                  _buildFilterDropdown("Departments", selectedDept),
                  const SizedBox(width: 40),
                  _buildFilterDatePicker("Date", selectedDate),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1D4D),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    ),
                    child: const Text("SEARCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ],
          ),
        ),

        // TABLE SECTION
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                Expanded(
                  child: ListView.separated(
                    itemCount: attendanceData.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _buildDataRow(attendanceData[index]),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B1D4D),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text("SUBMIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black26)),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: [value].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
            onChanged: (val) {},
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDatePicker(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black26)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(date), const Icon(Icons.calendar_today, size: 18)],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: const BoxDecoration(color: Color(0xFFA7BBC7), borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      child: const Row(
        children: [
          Expanded(child: Text("Emp ID", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(flex: 2, child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(child: Text("Attendance by", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(child: Text("Department", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(child: Text("In Time", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(child: Text("Out Time", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
          Expanded(child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildDataRow(Map<String, String> data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // FIXED: Replaced withOpacity with withValues
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(child: Text(data["id"]!, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(data["name"]!, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(data["by"]!)),
          Expanded(child: Text(data["dept"]!)),
          Expanded(child: _buildTimeBox(data["in"]!)),
          Expanded(child: _buildTimeBox(data["out"]!)),
          Expanded(child: _buildStatusBox(data["status"]!)),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String time) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(4)),
      alignment: Alignment.center,
      child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBox(String status) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(4)),
      alignment: Alignment.center,
      child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}