import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 
import 'leavedetails.dart';
import 'leavecalendar.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  String searchQuery = "";

  // Helper to convert Firestore Timestamp to String to prevent crash
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy').format(timestamp.toDate());
    }
    return timestamp?.toString() ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        _buildSearchBar(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // Points to 'leaves' collection
            stream: FirebaseFirestore.instance.collection('leaves').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              // Filter for 'Pending' requests (matches your DB value)
              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status']?.toString().toLowerCase() == 'pending';
              }).toList();

              if (docs.isEmpty) return const Center(child: Text("No pending requests."));

              return ListView.separated(
                padding: const EdgeInsets.all(32),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  String uid = data['userId'] ?? '';

                  // Fetch real employee name from 'users' collection using 'userId'
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                    builder: (context, userSnapshot) {
                      String name = "Unknown Employee";
                      String email = "N/A";
                      
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        name = userData['name'] ?? "Unknown";
                        email = userData['email'] ?? "N/A";
                      }

                      // Local search filter
                      if (searchQuery.isNotEmpty && !name.toLowerCase().contains(searchQuery.toLowerCase())) {
                        return const SizedBox.shrink();
                      }

                      return _buildLeaveRow(
                        context,
                        name: name,
                        type: data['type'] ?? 'Leave', 
                        date: "${_formatTimestamp(data['from'])} - ${_formatTimestamp(data['to'])}",
                        requestId: docs[index].id,
                        staffUid: uid,
                        detailsData: data,
                        userEmail: email,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Action logic for Approve/Reject with Notification
  Future<void> _processLeaveAction(BuildContext context, String docId, String staffUid, String status) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Update the leave status in 'leaves'
      batch.update(FirebaseFirestore.instance.collection('leaves').doc(docId), {'status': status});

      // Create a notification for the employee
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5), 
        border: Border(bottom: BorderSide(color: Color(0xFF0B1D4D), width: 3))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Leave Requests", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Review and manage employee absences", style: TextStyle(color: Colors.grey)),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveCalendarPage())),
            icon: const Icon(Icons.calendar_month, size: 18),
            label: const Text("Calendar View"),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1D4D), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: "Search by employee name...",
          prefixIcon: const Icon(Icons.search),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildLeaveRow(BuildContext context, {
    required String name, 
    required String type, 
    required String date, 
    required String requestId, 
    required String staffUid, 
    required Map<String, dynamic> detailsData,
    required String userEmail,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(type, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ),
        _buildActionButton(
          icon: Icons.check, 
          color: Colors.green, 
          bgColor: const Color(0xFFC8E6C9), 
          onTap: () => _processLeaveAction(context, requestId, staffUid, 'approved')
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.close, 
          color: Colors.red, 
          bgColor: const Color(0xFFFFCDD2), 
          isCircle: true, 
          onTap: () => _processLeaveAction(context, requestId, staffUid, 'rejected')
        ),
        IconButton(
          icon: const Icon(Icons.visibility_outlined),
          onPressed: () => showDialog(
            context: context, 
            builder: (context) => LeaveDetailsPage(
              requestId: requestId, 
              employeeDocId: staffUid, 
              name: name, 
              id: staffUid, 
              department: detailsData['department'] ?? 'General', 
              position: detailsData['position'] ?? 'Staff', 
              email: userEmail, 
              phone: detailsData['phone'] ?? 'N/A', 
              totalDays: '1', 
              leaveType: type, 
              startDate: _formatTimestamp(detailsData['from']), 
              endDate: _formatTimestamp(detailsData['to']), 
              reason: detailsData['reason'] ?? 'No reason provided',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required Color bgColor, required VoidCallback onTap, bool isCircle = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36, height: 36, 
        decoration: BoxDecoration(
          color: bgColor, 
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle, 
          borderRadius: isCircle ? null : BorderRadius.circular(4)
        ),
        child: Icon(icon, color: color, size: 20)
      ),
    );
  }
}