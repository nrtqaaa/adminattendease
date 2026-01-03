import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your sub-pages
import 'employeelist.dart';
import 'leaverequest.dart';
import 'leavebalance.dart';
import 'daily_attendance_view.dart';  
import 'monthly_report.dart';         
import 'payslip_management.dart';     
import 'system_config.dart';          
import 'manual_attendance.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _activePage = 'Dashboard';

  Widget _buildMainContent() {
    switch (_activePage) {
      case 'Employees': return const EmployeeList();
      case 'Attendance': return const DailyAttendancePage();
      case 'Manual Entry': return const ManualAttendancePage(); 
      case 'Leave Requests': return const LeaveRequestPage();
      case 'Leave Balance': return const LeaveBalancePage();
      case 'Reports': return const MonthlyReportPage();   
      case 'Payroll': return const PayslipManagementPage(); 
      case 'Settings': return const SystemConfigPage(); 
      case 'Dashboard':
      default: return _dashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // SIDEBAR
          Container(
            width: 250,
            color: const Color(0xFF000080), 
            child: Column(
              children: [
                const SizedBox(height: 40),
                const ListTile(
                  leading: Icon(Icons.business_center, color: Colors.white),
                  title: Text('AttendEase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(height: 20),
                _navItem(Icons.home, 'Dashboard'),
                _navItem(Icons.people, 'Employees'),
                _navItem(Icons.access_time, 'Attendance'),
                _navItem(Icons.edit_calendar, 'Manual Entry'),
                _navItem(Icons.calendar_today, 'Leave Requests'),
                _navItem(Icons.account_balance_wallet, 'Leave Balance'),
                _navItem(Icons.assignment, 'Reports'),
                _navItem(Icons.attach_money, 'Payroll'),
                _navItem(Icons.settings, 'Settings'),
                const Spacer(),
                // Logout Logic
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  onTap: () => FirebaseAuth.instance.signOut(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // MAIN CONTENT
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title) {
    bool isSelected = _activePage == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.yellow : Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: () => setState(() => _activePage = title),
    );
  }

  Widget _dashboardView() {
     return const Center(child: Text("Welcome to Admin Dashboard Content"));
     // You can paste your _statCard and _leaveItem code here
  }
}