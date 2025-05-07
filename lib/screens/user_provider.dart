import 'package:flutter/material.dart';

class UserProvider extends InheritedWidget {
  final String? email;
  final String username;
  final String accountType;
  final String? profilePicture;
  final int freeItemsPostedThisMonth;

  const UserProvider({
    super.key,
    required super.child,
    this.email,
    required this.username,
    required this.accountType,
    this.profilePicture,
    this.freeItemsPostedThisMonth = 0,
  });

  static UserProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserProvider>();
  }

  @override
  bool updateShouldNotify(UserProvider oldWidget) {
    return email != oldWidget.email ||
        username != oldWidget.username ||
        accountType != oldWidget.accountType ||
        profilePicture != oldWidget.profilePicture ||
        freeItemsPostedThisMonth != oldWidget.freeItemsPostedThisMonth;
  }
}

class UserState extends StatefulWidget {
  final Widget child;

  const UserState({super.key, required this.child});

  // Add a static method to access the state
  static _UserStateState? of(BuildContext context) {
    return context.findAncestorStateOfType<_UserStateState>();
  }

  @override
  State<UserState> createState() => _UserStateState();
}

class _UserStateState extends State<UserState> {
  String? _email;
  String _username = "Guest";
  String _accountType = "Basic";
  String? _profilePicture;
  int _freeItemsPostedThisMonth = 0;

  String? get email => _email;
  String get username => _username;
  String get accountType => _accountType;
  String? get profilePicture => _profilePicture;
  int get freeItemsPostedThisMonth => _freeItemsPostedThisMonth;

  void login(String email) {
    setState(() {
      _email = email;
      _username = email.split('@')[0];
      _accountType = "PRO";
      _profilePicture = null;
      debugPrint(
        'UserState: Logged in with email: $email, username: $_username',
      );
    });
  }

  void logout() {
    setState(() {
      _email = null;
      _username = "Guest";
      _accountType = "Basic";
      _profilePicture = null;
      _freeItemsPostedThisMonth = 0;
      debugPrint('UserState: Logged out, email reset to null');
    });
  }

  void updateProfile({
    String? username,
    String? accountType,
    String? profilePicture,
  }) {
    setState(() {
      _username = username ?? _username;
      _accountType = accountType ?? _accountType;
      _profilePicture = profilePicture ?? _profilePicture;
      debugPrint(
        'UserState: Profile updated, username: $_username, accountType: $_accountType',
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

  void updateAccountType(String newAccountType) {
    setState(() {
      _accountType = newAccountType;
      debugPrint('UserState: Account type updated to: $_accountType');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('UserState: Building with email: $_email, username: $_username');
    return UserProvider(
      email: _email,
      username: _username,
      accountType: _accountType,
      profilePicture: _profilePicture,
      freeItemsPostedThisMonth: _freeItemsPostedThisMonth,
      child: widget.child,
    );
  }
}
