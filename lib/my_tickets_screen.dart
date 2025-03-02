import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyTicketsScreen extends StatefulWidget {
  @override
  _MyTicketsScreenState createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<Map<String, dynamic>> parkTickets = [];
  List<Map<String, dynamic>> rideTickets = [];

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    var url = Uri.parse("http://10.0.2.2/amusement_park/get_tickets.php");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        parkTickets = List<Map<String, dynamic>>.from(data["park_tickets"]);
        rideTickets = List<Map<String, dynamic>>.from(data["ride_tickets"]);
      });
    }
  }

  Future<void> deleteTicket(String type, int id) async {
    var url = Uri.parse("http://10.0.2.2/amusement_park/delete_ticket.php");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"type": type, "id": id}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["success"]) {
        fetchTickets();
      }
    }
  }

  void confirmDelete(String type, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ยืนยันการยกเลิก"),
        content: Text("คุณต้องการยกเลิกตั๋วนี้ใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              deleteTicket(type, id);
              Navigator.pop(context);
            },
            child: Text("ยืนยัน"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ตั๋วของตนเอง")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade300], // สีพื้นหลังเหมือน BuyParkTicketScreen
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            if (parkTickets.isNotEmpty) ...[
              Text("ตั๋วเข้าสวนสนุก", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...parkTickets.map((ticket) => buildTicketItem(ticket, "park")),
            ],
            if (rideTickets.isNotEmpty) ...[
              SizedBox(height: 16),
              Text("ตั๋วเครื่องเล่น", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...rideTickets.map((ticket) => buildTicketItem(ticket, "ride")),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildTicketItem(Map<String, dynamic> ticket, String type) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text("${ticket['ticket_type'] ?? ticket['ride_name']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text("รหัสตั๋ว: ${ticket['id']}", style: TextStyle(color: Colors.grey[700])),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => confirmDelete(type, int.parse(ticket['id'].toString())),
        ),
      ),
    );
  }
}
