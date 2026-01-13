import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  
  // Helper to convert Firestore Timestamp to String
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy').format(timestamp.toDate());
    }
    return timestamp?.toString() ?? 'N/A';
  }

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
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Total Employees
        _dynamicStatCard("Total Employees", "users", Icons.groups_outlined, Colors.blue),
        
        // 2. Present Today (Filters by 'present' and current date)
        _dynamicStatCard(
          "Present Today", 
          "attendance", 
          Icons.check_circle_outline, 
          Colors.green,
          query: (ref) => ref.where('status', isEqualTo: 'present').where('date', isEqualTo: today),
        ),
        
        // 3. Pending Leave Requests
        _dynamicStatCard(
          "Leave Requests", 
          "leaves", 
          Icons.warning_amber_rounded, 
          Colors.orange,
          query: (ref) => ref.where('status', isEqualTo: 'Pending'),
        ),

        // 4. Absent Today calculation
        _buildAbsentCard(today),
      ],
    );
  }

  Widget _buildAbsentCard(String today) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('attendance')
              .where('status', isEqualTo: 'present')
              .where('date', isEqualTo: today)
              .snapshots(),
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

  Widget _dynamicStatCard(String label, String collection, IconData icon, Color color, {Query Function(CollectionReference)? query}) {
    CollectionReference colRef = FirebaseFirestore.instance.collection(collection);
    Stream<QuerySnapshot> stream = (query != null) ? query(colRef).snapshots() : colRef.snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
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
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey)),
        ],
      ),
    );
  }

  // --- SYNCED PENDING LEAVE SECTION ---
  Widget _buildPendingLeaveSection() {
    return Container(
      width: double.infinity,
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
                .collection('leaves')
                .where('status', isEqualTo: 'Pending')
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
                  String dateRange = "${_formatTimestamp(data['from'])} - ${_formatTimestamp(data['to'])}";

                  return _leaveRequestItem(
                    doc.id,
                    data['name'] ?? 'Unknown',
                    data['type'] ?? 'Leave',
                    dateRange,
                    data['userId'] ?? '',
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _leaveRequestItem(String docId, String name, String type, String date, String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(type, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
            onPressed: () => _updateLeaveStatus(docId, uid, 'approved'),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
            onPressed: () => _updateLeaveStatus(docId, uid, 'rejected'),
          ),
        ],
      ),
    );
  }

  // --- FIRESTORE UPDATE + NOTIFICATION LOGIC ---
  Future<void> _updateLeaveStatus(String docId, String staffUid, String status) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update Leave doc
      batch.update(FirebaseFirestore.instance.collection('leaves').doc(docId), {'status': status});

      // 2. Add Notification doc
      if (staffUid.isNotEmpty) {
        batch.set(FirebaseFirestore.instance.collection('notifications').doc(), {
          'userId': staffUid,
          'title': 'Leave Request ${status[0].toUpperCase()}${status.substring(1)}',
          'message': 'Your leave request has been $status.',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'type': 'leave_status'
        });
      }

      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request $status successfully"), backgroundColor: status == 'approved' ? Colors.green : Colors.red)
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}