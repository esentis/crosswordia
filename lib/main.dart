import 'package:crosswordia/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await supa.Supabase.initialize(
    url: 'https://qentdybmuxhxraaxrkol.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFlbnRkeWJtdXhoeHJhYXhya29sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI5MzM3MTcsImV4cCI6MjA1ODUwOTcxN30.vlEuxeKcjD97N3_S4zgvgSfg-ReNXC_zVLAIVDOrUEY',
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crosswordia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
