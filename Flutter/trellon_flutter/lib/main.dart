import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
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
      theme: AppTheme.light,
      routes: AppRoutes.routes,
      // Mặc định vào trang đăng nhập.
      // Sau này sẽ kiểm tra trạng thái đăng nhập để redirect tương ứng.
      initialRoute: '/login',
    );
  }
}
