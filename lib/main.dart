import 'package:crosswordia/providers/auth_provider.dart';
import 'package:crosswordia/screens/home.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await supa.Supabase.initialize(
    url: 'https://sjfnhxutysrunsyicixl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqZm5oeHV0eXNydW5zeWljaXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE2Nzk5MzkyOTIsImV4cCI6MTk5NTUxNTI5Mn0.svTYH93Fn_6n7xTGjHxo5GZyk_Vl3DMdTE4dBtQOnBE',
  );

  runApp(const MyApp());
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        Provider<PlayerStatusService>(
          create: (_) => PlayerStatusService.instance,
          lazy: true,
        ),
      ],
      child: MaterialApp(
        title: 'Crosswordia',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
