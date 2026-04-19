import 'package:apptreolon/features/profile/presentation/pages/profile_page.dart';
import 'package:apptreolon/features/profile/presentation/pages/security_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'routes.dart';
import 'init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.userProfile,
      routes: AppRoutes.routes,
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
