import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimManagementPage extends StatefulWidget {
  const ClaimManagementPage({super.key});

  @override
  State<ClaimManagementPage> createState() => _ClaimManagementPageState();
}

class _ClaimManagementPageState extends State<ClaimManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

  // --- DATABASE LOGIC: Update Claim Status ---
  Future<void> _updateClaimStatus(String docId, String newStatus) async {
    try {
      await _firestore.collection('claims').doc(docId).update({
        'status': newStatus,
        'reviewedAt': FieldValue.serverTimestamp(),
      });
      
      if (!mounted) return; // Fix for use_build_context_synchronously

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Claim marked as $newStatus")),
      );
    } catch (e) {
      debugPrint("Error updating claim: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Claim Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Welcome back, Admin", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 24),

          // SEARCH FILTER
          _buildSearchField(),
          const SizedBox(height: 24),

          // MANAGEMENT TABLE
          _buildManagementHeader(["Employee", "Type", "Description", "Amount", "Date", "Status", "Action"]),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('claims').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error fetching data"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs;

                // Simple Search Filtering
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    String name = (data['name'] ?? '').toString().toLowerCase();
                    String id = (data['employeeId'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery.toLowerCase()) || id.contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String docId = docs[index].id;

                    return _buildManagementRow(
                      docId,
                      data['name'] ?? 'Unknown',
                      data['employeeId'] ?? '-',
                      data['type'] ?? '-',
                      data['description'] ?? '-',
                      data['amount'] ?? '0',
                      data['date'] ?? '-',
                      data['status'] ?? 'Pending',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSearchField() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: const InputDecoration(
          hintText: "Search by name or employee ID",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildManagementHeader(List<String> labels) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Color(0xFFA7BBC7)),
      child: Row(
        children: labels.map((l) => Expanded(child: Text(l, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))).toList(),
      ),
    );
  }

  Widget _buildManagementRow(String docId, String name, String id, String type, String desc, String amount, String date, String status) {
    bool isPending = status.toLowerCase() == "pending";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(id, style: const TextStyle(fontSize: 12)),
            ],
          )),
          Expanded(child: Text(type)),
          Expanded(child: Text(desc)),
          Expanded(child: Text("RM $amount", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(date)),
          Expanded(child: _buildStatusBadge(status)),
          Expanded(
            child: isPending 
              ? Row(
                  children: [
                    InkWell(
                      onTap: () => _updateClaimStatus(docId, "Approved"),
                      child: _buildStatusIcon(Icons.check, Colors.green, Colors.green.withValues(alpha: 0.2)),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _updateClaimStatus(docId, "Rejected"),
                      child: _buildStatusIcon(Icons.close, Colors.red, Colors.red.withValues(alpha: 0.2)),
                    ),
                  ],
                )
              : const Text("Processed", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // FIXED: Added missing _buildStatusBadge method
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.orange; // Pending
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // FIXED: Added missing _buildStatusIcon method
  Widget _buildStatusIcon(IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}