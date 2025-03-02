import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyParkTicketScreen extends StatefulWidget {
  @override
  _BuyParkTicketScreenState createState() => _BuyParkTicketScreenState();
}

class _BuyParkTicketScreenState extends State<BuyParkTicketScreen> {
  Map<String, int> ticketCounts = {
    "ธรรมดา": 0,
    "VIP": 0
  };

  Map<String, int> ticketPrices = {
    "ธรรมดา": 100,
    "VIP": 200
  };

  Future<void> sendTicketDataToServer(String ticketType, int quantity) async {
    var url = Uri.parse("http://10.0.2.2/amusement_park/save_ticket.php");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ticket_type": ticketType, "quantity": quantity}),
    );

    print("📡 Response: ${response.body}");

    try {
      var responseData = jsonDecode(response.body);
      if (responseData["success"]) {
        print("✅ บันทึกสำเร็จ: ${responseData["message"]}");
      } else {
        print("❌ เกิดข้อผิดพลาด: ${responseData["message"]}");
      }
    } catch (e) {
      print("⚠️ JSON Decode Error: $e");
    }
  }

  void confirmPurchase() {
    setState(() {
      ticketCounts.forEach((type, count) {
        if (count > 0) {
          sendTicketDataToServer(type, count);
        }
      });
      ticketCounts.updateAll((key, value) => 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ซื้อตั๋วเข้าสวนสนุก")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ...ticketCounts.keys.map((type) => buildTicketOption(type)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: confirmPurchase,
                child: Text("ยืนยันการซื้อ"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTicketOption(String type) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text("ตั๋ว$type", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text("ราคา ${ticketPrices[type]} บาท", style: TextStyle(fontSize: 16, color: Colors.green)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (ticketCounts[type]! > 0) {
                    ticketCounts[type] = ticketCounts[type]! - 1;
                  }
                });
              },
            ),
            Text(ticketCounts[type].toString(), style: TextStyle(fontSize: 18)),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  ticketCounts[type] = ticketCounts[type]! + 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
