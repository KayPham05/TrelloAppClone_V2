import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'routes.dart';
import 'init_dependencies.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  
  final prefs = await SharedPreferences.getInstance();
  final isLogged = prefs.getBool('isLogged') ?? false;

  runApp(MyApp(isLogged: isLogged));
}

class MyApp extends StatelessWidget {
  final bool isLogged;

  const MyApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trello Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routes: AppRoutes.routes,
      builder: (context, child) {
        return _AppWarmup(child: child ?? const SizedBox.shrink());
      },
      initialRoute: isLogged ? AppRoutes.home : AppRoutes.login,
    );
  }
}

class _AppWarmup extends StatefulWidget {
  final Widget child;

  const _AppWarmup({required this.child});

  @override
  State<_AppWarmup> createState() => _AppWarmupState();
}

class _AppWarmupState extends State<_AppWarmup> {
  static final List<ImageProvider<Object>> _criticalImages = [
    CachedNetworkImageProvider('https://i.pravatar.cc/150?u=jordan'),
  ];

  bool _didWarmup = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didWarmup) return;
    _didWarmup = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final imageProvider in _criticalImages) {
        await precacheImage(imageProvider, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
