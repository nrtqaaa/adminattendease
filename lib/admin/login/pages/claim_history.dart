import 'package:flutter/material.dart';

class ClaimHistoryPage extends StatelessWidget {
  const ClaimHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Claim History", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("55 Total Claims", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
        ),

        // SEARCH CARD
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Claims", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              Row(
                children: [
                  _buildSearchInput("Claims Type", 300),
                  const SizedBox(width: 32),
                  _buildSearchInput("Date", 200),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1D4D),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                    child: const Text("SEARCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // HISTORY TABLE
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildTableHeader(["Claim ID", "Name", "Email", "Claim Type", "Action"]),
                Expanded(
                  child: ListView(
                    children: [
                      _buildHistoryRow("CLM001", "Anastasia Kim", "kistasia@ds.com", "Insurance"),
                      _buildHistoryRow("CLM002", "Ruqaiyah", "meliyah@ds.com", "Car Insurance"),
                      _buildHistoryRow("CLM003", "Dina Adreana", "adreadian@ds.com", "Health Insurance"),
                      _buildHistoryRow("CLM004", "Nuha Marsya", "mnuhas@ds.com", "Health Insurance"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInput(String label, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: width,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(List<String> labels) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Color(0xFFA7BBC7)),
      child: Row(
        children: labels.map((l) => Expanded(child: Text(l, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))).toList(),
      ),
    );
  }

  Widget _buildHistoryRow(String id, String name, String email, String type) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          Expanded(child: Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(email)),
          Expanded(child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold))),
          const Expanded(child: Icon(Icons.edit_note, size: 28)),
        ],
      ),
    );
  }
}