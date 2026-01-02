import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Ensure you have flutter pub add fl_chart

class MonthlyReportPage extends StatelessWidget {
  const MonthlyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F0F4),
      body: Column(
        children: [
          // Header
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Section
                  _buildSearchSection(),
                  const SizedBox(height: 30),

                  // Summary Statistics Grid
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildStatCard("Total Presents", "76"),
                      _buildStatCard("Total Absents", "20"),
                      _buildStatCard("Total Late", "15"),
                      _buildStatCard("Total Leave", "10"),
                      _buildStatCard("Missed Check-ins", "5"),
                      _buildStatCard("Total Claims", "30"),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Pie Chart Section
                  _buildChartSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFFD9D9D9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Report",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "Today's overview",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const Icon(Icons.logout_rounded),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // FIXED: Replaced withOpacity with withValues for newer Flutter versions
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Employees Monthly Reports",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDropdown("Departments"),
              const SizedBox(width: 20),
              _buildDropdown("Date", isDate: true),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000080),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                ),
                child: const Text(
                  "SEARCH",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // PIE CHART
          SizedBox(
            height: 250,
            width: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF000080),
                    value: 76,
                    radius: 50,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: 30,
                    radius: 50,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    color: Colors.yellow[700],
                    value: 20,
                    radius: 50,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    color: Colors.greenAccent[400],
                    value: 15,
                    radius: 50,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    color: Colors.purple[300],
                    value: 10,
                    radius: 50,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    color: Colors.blueAccent,
                    value: 5,
                    radius: 50,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 60),
          // LEGEND
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(const Color(0xFF000080), "Total Presents"),
              _buildLegendItem(Colors.red, "Total Claims"),
              _buildLegendItem(Colors.yellow[700]!, "Total Absents"),
              _buildLegendItem(Colors.greenAccent[400]!, "Total Late"),
              _buildLegendItem(Colors.purple[300]!, "Total Leave"),
              _buildLegendItem(Colors.blueAccent, "Missed Check-ins"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, {bool isDate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3E8FF),
            border: Border.all(color: Colors.black26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "v",
                style: TextStyle(color: Colors.transparent),
              ), // Spacing
              Icon(isDate ? Icons.calendar_month : Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ],
    );
  }
}