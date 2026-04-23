import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/providers/location_provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/providers/chat_provider.dart';
// Removed unused imports
import 'package:taskhub/screens/onboarding/splash.dart';
import 'package:taskhub/theme/const_value.dart';
// Removed unused imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize OneSignal (new 5.x API)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("eb54e4c5-a81c-4275-8956-b24dcb1571e3");
  // Prompt the user for push permissions on iOS (no-op on Android 13-).
  OneSignal.Notifications.requestPermission(true).then((accepted) {
    debugPrint("OneSignal permission accepted: $accepted");
  });

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
        ChangeNotifierProvider(create: (_) => ChatProvider()),
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
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: const Splash(),
      ),
    );
  }
}
