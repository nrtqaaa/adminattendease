import 'package:flutter/material.dart';
import 'leavedetails.dart';
import 'leavecalendar.dart'; // IMPORT THE NEW CALENDAR FILE

class LeaveRequestPage extends StatelessWidget {
  const LeaveRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0E0),
            border: Border(bottom: BorderSide(color: Colors.blue, width: 3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Leave Request", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Welcome back, Admin", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
              // --- NEW CALENDAR BUTTON ---
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LeaveCalendarPage()),
                  );
                },
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
        ),

        // MAIN CONTENT (Existing List)
        Expanded(
          child: SingleChildScrollView(
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
                  const Text("Pending Leave Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),

                  _buildLeaveRow(
                    context,
                    name: "Alice Wong",
                    type: "Annual Leave",
                    date: "Dec 15 - 17",
                    showApprove: false,
                    customViewColor: Colors.teal,
                    detailsData: const {
                      "id": "EMP002", "dept": "IT", "pos": "Software Engineer",
                      "email": "awong@ds.com", "phone": "+60123456789",
                      "start": "15/12/2025", "end": "17/12/2025", "days": "3 Days",
                      "reason": "Family vacation to Langkawi.",
                    },
                  ),
                  const Divider(height: 32),
                  
                  _buildLeaveRow(
                    context,
                    name: "Husna Aqilah",
                    type: "Annual Leave",
                    date: "Dec 10",
                    detailsData: const {
                      "id": "EMP003", "dept": "Marketing", "pos": "Marketing Exec",
                      "email": "haqilah@ds.com", "phone": "+60177788899",
                      "start": "10/12/2025", "end": "10/12/2025", "days": "1 Day",
                      "reason": "Medical appointment.",
                    },
                  ),
                  const Divider(height: 32),

                  _buildLeaveRow(
                    context,
                    name: "Amir Hazim",
                    type: "Personal Leave",
                    date: "Dec 20-21",
                    detailsData: const {
                      "id": "EMP004", "dept": "Sales", "pos": "Sales Rep",
                      "email": "ahazim@ds.com", "phone": "+60199900011",
                      "start": "20/12/2025", "end": "21/12/2025", "days": "2 Days",
                      "reason": "Family wedding.",
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveRow(BuildContext context, {required String name, required String type, required String date, required Map<String, String> detailsData, bool showApprove = true, Color customViewColor = Colors.blueGrey}) {
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
          if (showApprove) ...[
            Padding(padding: const EdgeInsets.only(right: 10), child: IconButton(icon: Container(width: 35, height: 35, decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.green)), child: const Icon(Icons.check, color: Colors.green, size: 20)), onPressed: () {})),
            Padding(padding: const EdgeInsets.only(right: 10), child: IconButton(icon: Container(width: 35, height: 35, decoration: BoxDecoration(color: const Color(0xFFFFCDD2), shape: BoxShape.circle, border: Border.all(color: Colors.red)), child: const Icon(Icons.close, color: Colors.red, size: 20)), onPressed: () {})),
          ],
          if (!showApprove)
             Padding(padding: const EdgeInsets.only(right: 10), child: Container(width: 35, height: 35, decoration: BoxDecoration(color: const Color(0xFFFFCDD2), shape: BoxShape.circle, border: Border.all(color: Colors.red)), child: const Icon(Icons.close, color: Colors.red, size: 20))),

          GestureDetector(
            onTap: () => showDialog(context: context, builder: (context) => LeaveDetailsPage(
              name: name, id: detailsData["id"]!, department: detailsData["dept"]!, position: detailsData["pos"]!,
              email: detailsData["email"]!, phone: detailsData["phone"]!, leaveType: type, startDate: detailsData["start"]!,
              endDate: detailsData["end"]!, totalDays: detailsData["days"]!, reason: detailsData["reason"]!,
            )),
            child: Container(
              width: 35, height: 35,
              decoration: BoxDecoration(color: showApprove ? Colors.grey[300] : Colors.teal[100], shape: showApprove ? BoxShape.circle : BoxShape.rectangle, borderRadius: showApprove ? null : BorderRadius.circular(4)),
              child: Icon(Icons.remove_red_eye, color: showApprove ? Colors.grey[700] : Colors.teal, size: 20),
            ),
          ),
        ]),
      ],
    );
  }
}