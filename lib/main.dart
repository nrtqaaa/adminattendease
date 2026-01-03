import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import your pages using relative paths
import 'admin/login/pages/login.dart'; 
import 'admin/login/pages/dashboard.dart'; // Ensure this file has DashboardContent
import 'admin/login/pages/employeelist.dart';
import 'admin/login/pages/daily_attendance_view.dart';
import 'admin/login/pages/manual_attendance.dart';
import 'admin/login/pages/leaverequest.dart';
import 'admin/login/pages/leavebalance.dart'; 
import 'admin/login/pages/payslip_management.dart'; 
import 'admin/login/pages/monthly_report.dart';
import 'admin/login/pages/system_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AttendEaseApp());
}

class AttendEaseApp extends StatelessWidget {
  const AttendEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AttendEase Admin',
      theme: ThemeData(
        primaryColor: const Color(0xFF0B1D4D),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const AdminDashboard();
        }
        return const LoginPage(); 
      },
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  // FIX: Replaced AdminDashboard() with DashboardContent() to avoid infinite loop
  final List<Widget> _pages = [
    const DashboardContent(), // This should be defined in dashboard.dart
    const EmployeeList(),
    const DailyAttendancePage(),
    const ManualAttendancePage(),
    const LeaveRequestPage(),
    const LeaveBalancePage(),
    const PayslipManagementPage(),
    const MonthlyReportPage(),
    const SystemConfigPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 200,
            backgroundColor: const Color(0xFF0B1D4D),
            unselectedIconTheme: const IconThemeData(color: Colors.white60),
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white60),
            selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.people), label: Text('Employees')),
              NavigationRailDestination(icon: Icon(Icons.calendar_today), label: Text('Attendance')),
              NavigationRailDestination(icon: Icon(Icons.edit_calendar), label: Text('Manual')),
              NavigationRailDestination(icon: Icon(Icons.mail_outline), label: Text('Leave Requests')),
              NavigationRailDestination(icon: Icon(Icons.account_balance), label: Text('Leave Balance')),
              NavigationRailDestination(icon: Icon(Icons.account_balance_wallet), label: Text('Payroll')),
              NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text('Reports')),
              NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}