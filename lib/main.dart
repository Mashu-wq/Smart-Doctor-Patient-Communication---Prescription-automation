import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/constants.dart';
import 'package:medisafe/features/splash/presentation/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medisafe/firebase_options.dart'; // Import Firebase
// Import Firebase options for platform

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings
  await Firebase.initializeApp(
    // Initialize Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: 'medication_reminder',
        channelName: 'Medication Reminders',
        channelDescription: 'Reminders for taking medicines',
        defaultColor: Colors.teal,
        ledColor: Colors.white,
      )
    ],
    debug: true,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "eClinic",
        theme: ThemeData(
            primarySwatch: Colors.indigo,
            //scaffoldBackgroundColor: kPrimaryLightColor,
            appBarTheme: const AppBarTheme(color: kPrimaryColor)),
        home: const SplashScreen());
  }
}
