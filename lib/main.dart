import 'package:ecosense/providers/auth_provider.dart';
import 'package:ecosense/providers/sensor_provider.dart';
import 'package:ecosense/screens/auth/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      // Use MultiProvider if you have multiple providers
      providers: [
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()), // If needed
        // Add other providers here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECOSENSE',
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), //WelcomePage1(),
      theme: ThemeData.light(),
      // darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
    );
  }
}
