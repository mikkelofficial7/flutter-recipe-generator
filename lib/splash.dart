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
      backgroundColor: Colors.black54,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with opacity
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/images/bg.jpeg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
