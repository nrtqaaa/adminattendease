import 'package:flutter/material.dart';

class CompanySettingsPage extends StatelessWidget {
  const CompanySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Company Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _buildSectionTitle("Holiday Settings"),
          _buildHolidayTable(),
          const SizedBox(height: 40),
          _buildSectionTitle("Leave Types"),
          _buildLeaveTypesTable(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHolidayTable() {
    return _buildBaseTable(
      ["Holiday Name", "Date", "Type", "Notes", "Action"],
      [
        ["Hari Raya", "31/3/2025", "Celebration", "N/A", "edit"],
        ["Good Friday", "18/3/2025", "Public", "N/A", "edit"],
        ["Labour Day", "1/5/2025", "Public", "N/A", "edit"],
      ],
    );
  }

  Widget _buildLeaveTypesTable() {
    return _buildBaseTable(
      ["Leave Name", "Paid", "Days/Year", "Req Doc", "Carry Forward"],
      [
        ["Annual Leave", "true", "20", "false", "true"],
        ["Medical Leave", "true", "14", "true", "false"],
        ["Emergency", "false", "3", "false", "false"],
      ],
    );
  }

  Widget _buildBaseTable(List<String> headers, List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFA7BBC7), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(children: headers.map((h) => Expanded(child: Text(h, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))).toList()),
          ),
          ...rows.map((row) => Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
            child: Row(
              children: row.map((cell) {
                if (cell == "true") return const Expanded(child: Icon(Icons.check_circle, color: Colors.green));
                if (cell == "false") return const Expanded(child: Icon(Icons.cancel, color: Colors.red));
                if (cell == "edit") return const Expanded(child: Icon(Icons.edit_note));
                return Expanded(child: Text(cell));
              }).toList(),
            ),
          )),
        ],
      ),
    );
  }
}