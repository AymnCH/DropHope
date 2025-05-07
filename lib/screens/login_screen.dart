import 'package:drophope/database_helper.dart';
import 'package:drophope/screens/forgot_pass_screen.dart';
import 'package:drophope/screens/signup_screen.dart';
import 'package:drophope/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drophope/screens/google_auth_screen.dart';
import 'package:drophope/screens/user_provider.dart';
import '../widgets/show_auth_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('Attempting login...');
    if (_formKey.currentState!.validate()) {
      print('Form validated. Fetching user...');
      try {
        final user = await DatabaseHelper.instance.getUser(
          _emailController.text,
          _passwordController.text,
        );
        print('User fetched: $user');
        if (user != null && user['password'] == _passwordController.text) {
          final userState = UserState.of(context); // Changed to UserState.of
          print('User state: $userState');
          if (userState != null) {
            userState.login(_emailController.text);
            print('Navigating to TabsScreen...');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TabsScreen()),
            );
          } else {
            print('User state is null.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'User state not found. Please wrap the app with UserState.',
                ),
              ),
            );
          }
        } else {
          print('Invalid credentials.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      } catch (e) {
        print('Error during login: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      print('Form validation failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserState(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(35.h),
          child: AppBar(
            title: Image.asset(
              'assets/images/appbar.png',
              height: 40.h,
              fit: BoxFit.contain,
              width: 150.w,
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        body: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 120.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Connect Now !",
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color.fromARGB(255, 20, 12, 70),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "Please fill in the information below to log in.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color.fromARGB(255, 101, 100, 100),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10.r,
                              spreadRadius: 1.r,
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email address',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email address',
                                  labelStyle: TextStyle(fontSize: 14.sp),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40.r),
                                  ),
                                ),
                                style: TextStyle(fontSize: 14.sp),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  labelStyle: TextStyle(fontSize: 14.sp),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40.r),
                                  ),
                                ),
                                style: TextStyle(fontSize: 14.sp),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.h),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      67,
                                      118,
                                      199,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 100.w,
                                      vertical: 8.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                  ),
                                  child: Text(
                                    "Sign in",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const ForgotPass(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot your password?',
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        219,
                                        11,
                                        11,
                                      ),
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  'or',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFFFFF),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14.h,
                                        horizontal: 30.w,
                                      ),
                                    ),
                                    onPressed: () {
                                      showAuthDialog(
                                        context,
                                        const GoogleAuthScreen(),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/google.png',
                                          height: 30.h,
                                        ),
                                        SizedBox(width: 10.w),
                                        Text(
                                          "Log in with Google",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Don't have an account? Sign up",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          139,
                                          169,
                                          220,
                                        ),
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
