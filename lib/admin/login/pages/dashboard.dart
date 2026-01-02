import 'package:flutter/material.dart';

// 1. IMPORT ALL YOUR PAGES HERE
import 'employeelist.dart';
import 'leaverequest.dart';
import 'leavebalance.dart';
import 'daily_attendance_view.dart';  // For Attendance
import 'monthly_report.dart';         // For Reports
import 'payslip_management.dart';     // For Payroll (Ensure class name matches)
import 'system_config.dart';          // For Settings

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // This variable tracks which page is currently showing
  String _activePage = 'Dashboard';

  // 2. SWITCH LOGIC: Maps the sidebar names to the actual Pages
  Widget _buildMainContent() {
    switch (_activePage) {
      case 'Employees':
        return const EmployeeList();
      case 'Attendance':
        return const DailyAttendancePage(); // Linked to daily_attendance_view.dart
      case 'Leave Requests':
        return const LeaveRequestPage();
      case 'Leave Balance':
        return const LeaveBalancePage();
      case 'Reports':
        return const MonthlyReportPage();   // Linked to monthly_report.dart
      case 'Payroll':
        // NOTE: Ensure your payslip_management.dart has a class named PayslipManagementPage
        return const PayslipManagementPage(); 
      case 'Settings':
        return const SystemConfigurationPage(); // Linked to system_config.dart
      case 'Dashboard':
      default:
        return _dashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ================== SIDEBAR ==================
          Container(
            width: 250,
            color: const Color(0xFF000080), // Deep Blue Background
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo Area
                const ListTile(
                  leading: Icon(Icons.business_center, color: Colors.white),
                  title: Text(
                    'AttendEase', 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
                  ),
                ),
                const SizedBox(height: 20),
                
                // 3. SIDEBAR BUTTONS (Must match the 'case' names above exactly)
                _navItem(Icons.home, 'Dashboard'),
                _navItem(Icons.people, 'Employees'),
                _navItem(Icons.access_time, 'Attendance'),
                _navItem(Icons.calendar_today, 'Leave Requests'),
                _navItem(Icons.account_balance_wallet, 'Leave Balance'),
                _navItem(Icons.assignment, 'Reports'),
                _navItem(Icons.attach_money, 'Payroll'),
                _navItem(Icons.settings, 'Settings'),
                
                const Spacer(),
                _navItem(Icons.account_circle, 'Admin'),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ================== MAIN CONTENT AREA ==================
          Expanded(
            child: Container(
              color: const Color(0xFFE5EAEF), // Light Grey Background
              child: _buildMainContent(), // This renders the page selected in the switch
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to create Sidebar Buttons
  Widget _navItem(IconData icon, String title) {
    bool isSelected = _activePage == title;
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title, 
        style: TextStyle(
          color: Colors.white, 
          decoration: isSelected ? TextDecoration.underline : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        )
      ),
      onTap: () {
        setState(() {
          _activePage = title; // This triggers the screen update
        });
      },
    );
  }

  // ================== DEFAULT DASHBOARD VIEW ==================
  Widget _dashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Welcome back, Admin', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          
          // Summary Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statCard('7', 'Total Employees', Icons.groups, Colors.blue.shade50),
              _statCard('7', 'Present Today', Icons.check_box, Colors.green.shade50),
              _statCard('5', 'Leave Requests', Icons.priority_high, Colors.orange.shade50),
              _statCard('0', 'Absent Today', Icons.cancel, Colors.red.shade50),
            ],
          ),
          const SizedBox(height: 32),
          
          // Pending Requests Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pending Leave Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _leaveItem('Alice Wong', 'Annual Leave', 'Dec 15 - 17'),
                _leaveItem('Husna Aqilah', 'Sick Leave', 'Dec 10'),
                _leaveItem('Amir Hazim', 'Personal Leave', 'Dec 20 - 21'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String val, String label, IconData icon, Color color) {
    return Container(
      width: 150, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [Icon(icon, color: Colors.blueGrey), Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 10))]),
    );
  }

  Widget _leaveItem(String name, String type, String date) {
    return ListTile(
      title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text('$type • $date', style: const TextStyle(fontSize: 12)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_box, color: Colors.green[200]), const SizedBox(width: 8), Icon(Icons.cancel, color: Colors.red[200])]),
    );
  }
}