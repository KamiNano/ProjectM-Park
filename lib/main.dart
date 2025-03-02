import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'สวนสนุก',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent, // ทำให้พื้นหลัง Scaffold โปร่งแสง
      ),
      home: GradientBackground(child: HomeScreen()), // ใช้พื้นหลังไล่เฉดสี
    );
  }
}

// สร้าง Widget สำหรับพื้นหลังไล่เฉดสี
class GradientBackground extends StatelessWidget {
  final Widget child;
  GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.shade300,  // ไล่เฉดสีม่วง
            Colors.orange.shade300,  // ไล่เฉดสีส้ม
            Colors.yellow.shade200,  // ไล่เฉดสีเหลือง
          ],
        ),
      ),
      child: child, // แสดงหน้าต่างๆ ของแอปทับบนพื้นหลังนี้
    );
  }
}
