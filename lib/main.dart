import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'services/app_state.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found - will use system environment variables
  }
  
  // Initialize cameras
  try {
    cameras = await availableCameras();
  } catch (e) {
    // Error initializing cameras - silently continue
  }
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Error initializing Firebase - silently continue
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const WarehouseTrackerApp(),
    ),
  );
}

class WarehouseTrackerApp extends StatelessWidget {
  const WarehouseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warehouse Container Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}