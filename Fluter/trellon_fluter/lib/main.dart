import 'package:flutter/material.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trello Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1D2125),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF579DFF),
          surface: Color(0xFF282E33),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1D2125),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      routes: AppRoutes.routes,
      initialRoute: '/login',
    );
  }
}

