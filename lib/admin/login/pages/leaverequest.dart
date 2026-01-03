import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'leavedetails.dart';
import 'leavecalendar.dart';

class LeaveRequestPage extends StatelessWidget {
  const LeaveRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('leave_requests')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text("Error loading data"));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Pending Leave Requests", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      
                      if (docs.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No pending leave requests found."),
                        ))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (context, index) => const Divider(height: 32),
                          itemBuilder: (context, index) {
                            var data = docs[index].data() as Map<String, dynamic>;
                            String docId = docs[index].id;

                            return _buildLeaveRow(
                              context,
                              name: data['name'] ?? 'Unknown',
                              type: data['leaveType'] ?? 'Leave',
                              date: "${data['startDate']} - ${data['endDate']}",
                              requestId: docId,
                              detailsData: data,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- ACTIONS: Approve / Reject with Error Handling ---
  Future<void> _updateRequestStatus(BuildContext context, String docId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(docId)
          .update({'status': status});
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request ${status.toUpperCase()} successfully")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5), // Softened the grey slightly
        border: Border(bottom: BorderSide(color: Color(0xFF0B1D4D), width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Leave Request", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Welcome back, Admin", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveCalendarPage())),
            icon: const Icon(Icons.calendar_month, size: 18),
            label: const Text("Calendar View"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B1D4D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRow(BuildContext context, {
    required String name, 
    required String type, 
    required String date, 
    required String requestId,
    required Map<String, dynamic> detailsData
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(type, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ),
        Row(children: [
          // Approve
          _buildActionButton(
            icon: Icons.check, 
            color: Colors.green, 
            bgColor: const Color(0xFFC8E6C9), 
            onTap: () => _updateRequestStatus(context, requestId, 'approved'),
          ),
          const SizedBox(width: 10),
          // Reject
          _buildActionButton(
            icon: Icons.close, 
            color: Colors.red, 
            bgColor: const Color(0xFFFFCDD2), 
            isCircle: true,
            onTap: () => _updateRequestStatus(context, requestId, 'rejected'),
          ),
          const SizedBox(width: 10),
          // Details (Fixed dynamic call)
          GestureDetector(
            onTap: () => showDialog(
              context: context, 
              builder: (context) => LeaveDetailsPage( // const removed here
                requestId: requestId,
                employeeDocId: detailsData['employeeDocId'] ?? '',
                name: name,
                id: detailsData['employeeId'] ?? '',
                department: detailsData['dept'] ?? '',
                position: detailsData['pos'] ?? '',
                email: detailsData['email'] ?? '',
                phone: detailsData['phone'] ?? '',
                leaveType: type,
                startDate: detailsData['startDate'] ?? '',
                endDate: detailsData['endDate'] ?? '',
                totalDays: detailsData['totalDays'] ?? '',
                reason: detailsData['reason'] ?? '',
              ),
            ),
            child: Container(
              width: 35, height: 35,
              decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
              child: Icon(Icons.remove_red_eye, color: Colors.grey[700], size: 20),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required Color bgColor, required VoidCallback onTap, bool isCircle = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 35, height: 35, 
        decoration: BoxDecoration(
          color: bgColor, 
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(4),
          border: Border.all(color: color)
        ),
        child: Icon(icon, color: color, size: 20)
      ),
    );
  }
}