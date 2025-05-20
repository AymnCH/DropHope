import 'package:drophope/screens/admin_screens/admin_items_screen.dart';
import 'package:drophope/screens/admin_screens/admin_profile_screen.dart';
import 'package:drophope/screens/admin_screens/admin_reports_screen.dart';
import 'package:drophope/screens/admin_screens/admin_users_screen.dart';
import 'package:drophope/screens/login_screen.dart';
import 'package:drophope/screens/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Function(Widget) navigateToScreen;

  const AdminDashboardScreen({
    super.key,
    this.navigateToScreen = _defaultNavigate,
  });

  static void _defaultNavigate(Widget screen) {}

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 20, 12, 70),
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final userState = UserState.of(context);
                    if (userState != null) {
                      userState.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black,
    bool showTrailing = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: color, size: 30),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          color: color,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
      trailing:
          showTrailing ? const Icon(Icons.arrow_forward_ios, size: 19) : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = UserProvider.of(context);
    if (userProvider?.role != "admin") {
      return const Scaffold(
        body: Center(child: Text("Access Denied: Admins Only")),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 90,
          leadingWidth: 57,
          leading: SizedBox(
            height: 40,
            width: 40,
            child: Image.asset(
              "assets/images/Logo2.png",
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red, size: 40);
              },
            ),
          ),
          title: const Text(
            "Admin Dashboard",
            style: TextStyle(
              color: Color.fromRGBO(7, 68, 112, 1),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color.fromRGBO(7, 68, 112, 1),
            labelColor: Color.fromRGBO(7, 68, 112, 1),
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
            tabs: [
              Tab(text: "Reports"),
              Tab(text: "Items"),
              Tab(text: "Users"),
            ],
          ),
        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 130.h,
                color: Colors.indigo[50],
                child: Center(
                  child: Image.asset(
                    'assets/images/appbar.png',
                    height: 40.h,
                    fit: BoxFit.contain,
                    width: 150.w,
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.account_circle_sharp,
                title: 'Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminProfileScreen(),
                    ),
                  );
                },
              ),

              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Sign Out',
                color: Colors.red,
                showTrailing: false,
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminReportsScreen(),
            AdminItemsScreen(),
            AdminUsersScreen(),
          ],
        ),
      ),
    );
  }
}
