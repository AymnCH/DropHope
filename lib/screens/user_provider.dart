import 'package:drophope/main.dart';
import 'package:flutter/material.dart';
import 'package:drophope/database_helper.dart';

class UserProvider extends InheritedWidget {
  final String? email;
  final String username;
  final String accountType;
  final String? profilePicture;
  final int freeItemsPostedThisMonth;
  final String? role; // Add role field

  const UserProvider({
    super.key,
    required super.child,
    this.email,
    required this.username,
    required this.accountType,
    this.profilePicture,
    this.freeItemsPostedThisMonth = 0,
    this.role,
  });

  static UserProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserProvider>();
  }

  bool get isAdmin => role == 'admin'; // Getter to check if user is admin

  @override
  bool updateShouldNotify(UserProvider oldWidget) {
    return email != oldWidget.email ||
        username != oldWidget.username ||
        accountType != oldWidget.accountType ||
        profilePicture != oldWidget.profilePicture ||
        freeItemsPostedThisMonth != oldWidget.freeItemsPostedThisMonth ||
        role != oldWidget.role;
  }
}

class UserState extends StatefulWidget {
  final Widget child;

  const UserState({super.key, required this.child});

  static UserStateState? of(BuildContext context) {
    return userStateKey.currentState;
  }

  @override
  State<UserState> createState() => UserStateState();
}

class UserStateState extends State<UserState> {
  String? _email;
  String _username = "Guest";
  String _accountType = "BASIC";
  String? _profilePicture;
  int _freeItemsPostedThisMonth = 0;
  String? _role; // Add role field

  String? get email => _email;
  String get username => _username;
  String get accountType => _accountType;
  String? get profilePicture => _profilePicture;
  int get freeItemsPostedThisMonth => _freeItemsPostedThisMonth;
  String? get role => _role; // Getter for role
  bool get isAdmin => _role == 'admin'; // Getter to check if user is admin

  Future<void> login(String email) async {
    final dbHelper = DatabaseHelper.instance;
    final user = await dbHelper.getUserByEmail(email);
    setState(() {
      _email = email;
      _username = user?['full_name'] ?? email.split('@')[0];
      _accountType = user?['account_type'] ?? "BASIC";
      _profilePicture = user?['profile_picture'];
      _role = user?['role'] ?? 'user'; // Fetch role from database
      debugPrint(
        'UserState: Logged in with email: $email, username: $_username, accountType: $_accountType, profilePicture: $_profilePicture, role: $_role',
      );
    });
  }

  void logout() {
    setState(() {
      _email = null;
      _username = "Guest";
      _accountType = "BASIC";
      _profilePicture = null;
      _freeItemsPostedThisMonth = 0;
      _role = null; // Reset role on logout
      debugPrint('UserState: Logged out, email reset to null');
    });
  }

  Future<void> updateProfile({
    String? username,
    String? accountType,
    String? profilePicture,
    String? role, // Add role parameter for updates if needed
  }) async {
    if (profilePicture != null && _email != null) {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.updateUserProfilePicture(_email!, profilePicture);
    }
    setState(() {
      _username = username ?? _username;
      _accountType = accountType ?? _accountType;
      _profilePicture = profilePicture ?? _profilePicture;
      _role = role ?? _role; // Update role if provided
      debugPrint(
        'UserState: Profile updated, username: $_username, accountType: $_accountType, profilePicture: $_profilePicture, role: $_role',
      );
    });
  }

  void incrementFreeItemsPosted() {
    setState(() {
      _freeItemsPostedThisMonth++;
      debugPrint(
        'UserState: Free items posted this month: $_freeItemsPostedThisMonth',
      );
    });
  }

  Future<void> updateAccountType(String newAccountType) async {
    if (_email != null) {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.updateUserAccountType(_email!, newAccountType);
    }
    setState(() {
      _accountType = newAccountType;
      debugPrint('UserState: Account type updated to: $_accountType');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'UserState: Building with email: $_email, username: $_username, accountType: $_accountType, profilePicture: $_profilePicture, role: $_role',
    );
    return UserProvider(
      email: _email,
      username: _username,
      accountType: _accountType,
      profilePicture: _profilePicture,
      freeItemsPostedThisMonth: _freeItemsPostedThisMonth,
      role: _role, // Pass role to UserProvider
      child: widget.child,
    );
  }
}
