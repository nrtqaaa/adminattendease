import 'package:flutter/material.dart';

class SubmissionClaimReviewPage extends StatelessWidget {
  const SubmissionClaimReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F0F4),
      body: Column(
        children: [
          // Top Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: const Color(0xFFD9D9D9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Submission Claim Review",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Today's overview",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SUMMARY CARDS ---
                  Row(
                    children: [
                      _buildSummaryCard("Total number of open claims", "20", const Color(0xFFC5CAE9)),
                      const SizedBox(width: 20),
                      _buildSummaryCard("Pending claim form", "13", const Color(0xFFBDC3C7)),
                      const SizedBox(width: 20),
                      _buildSummaryCard("Total number of open claims", "55", const Color(0xFFBDC3C7)),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // --- PENDING REQUESTS SECTION ---
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pending Claim Requests",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView(
                              children: [
                                _buildClaimItem("Anastasia Kim", "Insurance", "RM 4523.20"),
                                _buildClaimItem("Ruqaiyah Melinda", "Car Insurance", "RM 80000.00"),
                                _buildClaimItem("Dina Adreana", "Health Insurance", "RM 142.78"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for the Top 3 Cards
  Widget _buildSummaryCard(String title, String count, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper Widget for the Claim List Row
  Widget _buildClaimItem(String name, String type, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              Text(type, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(amount, style: const TextStyle(fontSize: 12, color: Colors.black87)),
            ],
          ),
          const Spacer(),
          // Action Buttons (Green Check / Red X)
          Row(
            children: [
              // FIXED: Replaced withOpacity with withValues
              _buildActionButton(Icons.check, Colors.greenAccent.withValues(alpha: 0.3), Colors.green),
              const SizedBox(width: 10),
              // FIXED: Replaced withOpacity with withValues
              _buildActionButton(Icons.close, Colors.redAccent.withValues(alpha: 0.3), Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        // FIXED: Replaced withOpacity with withValues
        border: Border.all(color: iconColor.withValues(alpha: 0.5)),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}