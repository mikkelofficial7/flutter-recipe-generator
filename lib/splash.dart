import 'package:flutter/material.dart';
import 'package:flutter_recipe_generator/permission.dart';

class SplashApp extends StatefulWidget {
  const SplashApp({super.key});

  @override
  State<StatefulWidget> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PermissionHandler()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/splash.jpg'),
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
