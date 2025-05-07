import 'package:drophope/screens/welcome_screen.dart';
import 'package:drophope/screens/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return UserState(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'DropHope',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: const WelcomeScreen(),
          ),
        );
      },
    );
  }
}
