import 'package:drophope/screens/admin_screens/report_provider.dart';
import 'package:drophope/screens/welcome_screen.dart';
import 'package:drophope/screens/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

final GlobalKey<UserStateState> userStateKey = GlobalKey<UserStateState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize profile pictures directory
  final appDir = await getApplicationDocumentsDirectory();
  final profilePicturesDir = Directory('${appDir.path}/profile_pictures');
  if (!await profilePicturesDir.exists()) {
    await profilePicturesDir.create(recursive: true);
    debugPrint(
      'Main: Created profile pictures directory at ${profilePicturesDir.path}',
    );
  }
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
        return MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => ReportProvider())],
          child: UserState(
            key: userStateKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'DropHope',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              home: const WelcomeScreen(),
            ),
          ),
        );
      },
    );
  }
}
