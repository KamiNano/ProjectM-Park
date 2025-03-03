import 'package:flutter/material.dart';
import 'buy_ticket_screen.dart';
import 'buy_ride_ticket_screen.dart';
import 'map_screen.dart';
import 'my_tickets_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = "กำลังโหลด...";

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // โหลดชื่อจาก MySQL
  }

  // ดึงชื่อจากฐานข้อมูล
  Future<void> _fetchUsername() async {
    var url = Uri.parse("http://10.0.2.2/amusement_park/get_username.php");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        _username = data["username"];
      });
    } else {
      setState(() {
        _username = "โหลดชื่อผิดพลาด";
      });
    }
  }

  // อัปเดตชื่อในฐานข้อมูล
  Future<void> _updateUsername(String newUsername) async {
    var url = Uri.parse("http://10.0.2.2/amusement_park/update_username.php");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": newUsername}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["success"]) {
        setState(() {
          _username = newUsername;
        });
      }
    }
  }

  // แสดง Dialog เพื่อเปลี่ยนชื่อ
  void _editUsername() {
    TextEditingController controller = TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("แก้ไขชื่อผู้ใช้"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "ป้อนชื่อใหม่"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              _updateUsername(controller.text);
              Navigator.pop(context);
            },
            child: Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DinosaurPark"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _editUsername,
              child: Row(
                children: [
                  Text(_username, style: TextStyle(fontSize: 18)),
                  SizedBox(width: 6),
                  Icon(Icons.edit, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/dinosaur_logo.png",
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),

            MenuButton("🎟️ ซื้อบัตรเข้าสวนสนุก", context, BuyParkTicketScreen()),
            MenuButton("🎢 ตั๋วเข้าเล่นเครื่องเล่น", context, BuyRideTicketScreen()),
            MenuButton("🗺️ ดูแผนที่", context, ParkMapScreen()),
            MenuButton("📄 ตั๋วของตนเอง", context, MyTicketsScreen()),
          ],
        ),
      ),
    );
  }

  Widget MenuButton(String text, BuildContext context, Widget page) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: Text(text),
        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
      ),
    );
  }
}
