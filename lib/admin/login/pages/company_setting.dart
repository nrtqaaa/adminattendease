import 'package:flutter/material.dart';

class CompanySettingsPage extends StatefulWidget {
  const CompanySettingsPage({super.key});

  @override
  State<CompanySettingsPage> createState() => _CompanySettingsPageState();
}

class _CompanySettingsPageState extends State<CompanySettingsPage> {
  // Data moved into state so it can be edited
  List<List<String>> holidayRows = [
    ["Hari Raya", "31/3/2025", "Celebration", "N/A", "edit"],
    ["Good Friday", "18/3/2025", "Public", "N/A", "edit"],
    ["Labour Day", "1/5/2025", "Public", "N/A", "edit"],
  ];

  List<List<String>> leaveRows = [
    ["Annual Leave", "true", "20", "false", "true"],
    ["Medical Leave", "true", "14", "true", "false"],
    ["Emergency", "false", "3", "false", "false"],
  ];

  // Function to handle the edit action
  void _editHoliday(int index) {
    TextEditingController controller = TextEditingController(text: holidayRows[index][0]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Holiday Name"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                holidayRows[index][0] = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), backgroundColor: const Color(0xFFA7BBC7)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Company Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildSectionTitle("Holiday Settings"),
            _buildBaseTable(
              ["Holiday Name", "Date", "Type", "Notes", "Action"],
              holidayRows,
              isHolidayTable: true,
            ),
            const SizedBox(height: 40),
            _buildSectionTitle("Leave Types"),
            _buildBaseTable(
              ["Leave Name", "Paid", "Days/Year", "Req Doc", "Carry Forward"],
              leaveRows,
              isHolidayTable: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBaseTable(List<String> headers, List<List<String>> rows, {required bool isHolidayTable}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFA7BBC7), 
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: headers.map((h) => Expanded(
                child: Text(h, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )).toList(),
            ),
          ),
          // Rows
          ...rows.asMap().entries.map((entry) {
            int index = entry.key;
            List<String> row = entry.value;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
              child: Row(
                children: row.map((cell) {
                  if (cell == "true") return const Expanded(child: Icon(Icons.check_circle, color: Colors.green));
                  if (cell == "false") return const Expanded(child: Icon(Icons.cancel, color: Colors.red));
                  if (cell == "edit") {
                    return Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue),
                        onPressed: () => _editHoliday(index),
                      ),
                    );
                  }
                  return Expanded(child: Text(cell));
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}