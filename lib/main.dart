import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import your pages using relative paths
import 'admin/login/pages/login.dart'; 
import 'admin/login/pages/dashboard.dart'; 
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

  final List<Widget> _pages = [
    const DashboardContent(),
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
            minExtendedWidth: 240,
            backgroundColor: const Color(0xFF0B1D4D),
            unselectedIconTheme: const IconThemeData(color: Colors.white60),
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white60, fontSize: 14),
            selectedLabelTextStyle: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontSize: 14,
            ),
            // --- LOGO HEADER ---
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.business_center, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AttendEase',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.people_outline), label: Text('Employees')),
              NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), label: Text('Attendance')),
              NavigationRailDestination(icon: Icon(Icons.edit_calendar_outlined), label: Text('Manual')),
              NavigationRailDestination(icon: Icon(Icons.mail_outline), label: Text('Leave Requests')),
              NavigationRailDestination(icon: Icon(Icons.account_balance_outlined), label: Text('Leave Balance')),
              NavigationRailDestination(icon: Icon(Icons.payments_outlined), label: Text('Payroll')),
              NavigationRailDestination(icon: Icon(Icons.bar_chart_outlined), label: Text('Reports')),
              NavigationRailDestination(icon: Icon(Icons.settings_outlined), label: Text('Settings')),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            // --- BOTTOM PROFILE & LOGOUT ---
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0, left: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                        SizedBox(width: 12),
                        Text('Admin', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white60),
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Vertical divider to separate sidebar from content
          const VerticalDivider(thickness: 1, width: 1, color: Colors.black12),
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