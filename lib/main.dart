import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/providers/location_provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/screens/auths/forgot_password.dart';
import 'package:taskhub/screens/auths/reset_password.dart';
import 'package:taskhub/screens/auths/sign_in_user.dart';
import 'package:taskhub/screens/auths/verify_email.dart';
import 'package:taskhub/screens/user/home.dart';
import 'package:taskhub/screens/onboarding/onboard1.dart';
import 'package:taskhub/screens/onboarding/splash.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/waiting.dart';
import 'package:taskhub/widgets/custom_loader_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'TaskHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          scaffoldBackgroundColor: white,
          appBarTheme: AppBarTheme(
            backgroundColor: white,
          ),
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity
        ),
        home: const Splash(),
      ),
    );
  }
}

