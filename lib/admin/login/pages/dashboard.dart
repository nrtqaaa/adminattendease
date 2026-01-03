import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F2), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildStatCards(),
            const SizedBox(height: 30),
            _buildPendingLeaveSection(),
          ],
        ),
      ),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text("Welcome back, Admin", 
              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
          ],
        ),
        IconButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(Icons.logout_rounded, size: 28),
        )
      ],
    );
  }

  // --- DYNAMIC STATISTICS CARDS ---
  Widget _buildStatCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Change "users" to "employees" if your employee list is in that collection
        _dynamicStatCard("Total Employees", "users", Icons.groups_outlined, Colors.blue),
        
        _dynamicStatCard(
          "Present Today", 
          "attendance", 
          Icons.check_circle_outline, 
          Colors.green,
          query: (ref) => ref.where('status', isEqualTo: 'present'),
        ),
        
        _dynamicStatCard(
          "Leave Requests", 
          "leave_requests", 
          Icons.warning_amber_rounded, 
          Colors.orange,
          query: (ref) => ref.where('status', isEqualTo: 'pending'),
        ),

        // Logic for Absent: Usually Total Employees - Present Today
        _buildAbsentCard(),
      ],
    );
  }

  // SPECIAL CARD FOR ABSENT TODAY (Calculation)
  Widget _buildAbsentCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('attendance')
              .where('status', isEqualTo: 'present').snapshots(),
          builder: (context, attSnap) {
            int total = userSnap.hasData ? userSnap.data!.docs.length : 0;
            int present = attSnap.hasData ? attSnap.data!.docs.length : 0;
            int absent = total - present;
            if (absent < 0) absent = 0;

            return _statCard("Absent Today", absent.toString(), Icons.cancel_outlined, Colors.red);
          },
        );
      },
    );
  }

  // Helper Widget for Stream-based Counts
  Widget _dynamicStatCard(String label, String collection, IconData icon, Color color, {Query Function(CollectionReference)? query}) {
    CollectionReference colRef = FirebaseFirestore.instance.collection(collection);
    Stream<QuerySnapshot> stream = (query != null) ? query(colRef).snapshots() : colRef.snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _statCard(label, "Err", icon, color);
        String value = (snapshot.hasData) ? snapshot.data!.docs.length.toString() : "...";
        return _statCard(label, value, icon, color);
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9), 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- DYNAMIC PENDING LEAVE SECTION ---
  Widget _buildPendingLeaveSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pending Leave Requests", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('leave_requests')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("No pending requests found."),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _leaveRequestItem(
                    doc.id,
                    data['employeeName'] ?? 'Unknown',
                    data['leaveType'] ?? 'General',
                    data['dateRange'] ?? 'N/A',
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _leaveRequestItem(String docId, String name, String type, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_box, color: Color(0xFF90EE90), size: 30),
            onPressed: () => _updateLeaveStatus(docId, 'approved'),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.cancel, color: Color(0xFFFF6961), size: 30),
            onPressed: () => _updateLeaveStatus(docId, 'rejected'),
          ),
        ],
      ),
    );
  }

  // Helper to handle Firestore updates
  Future<void> _updateLeaveStatus(String docId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(docId)
          .update({'status': status});
    } catch (e) {
      debugPrint("Error updating leave: $e");
    }
  }
}