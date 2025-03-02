import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyRideTicketScreen extends StatefulWidget {
  @override
  _BuyRideTicketScreenState createState() => _BuyRideTicketScreenState();
}

class _BuyRideTicketScreenState extends State<BuyRideTicketScreen> {
  Map<String, int> rideTicketCounts = {
    "สกายโคสเตอร์": 0,
    "ชิงช้าสวรรค์": 0,
    "ม้าหมุน": 0,
    "สวนน้ำ": 0
  };

  Map<String, int> rideTicketPrices = {
    "สกายโคสเตอร์": 200,
    "ชิงช้าสวรรค์": 100,
    "ม้าหมุน": 100,
    "สวนน้ำ": 50
  };

  Future<void> sendRideTicketDataToServer(String rideName, int quantity) async {
    var url = Uri.parse("http://10.0.2.2/amusement_park/save_ride_ticket.php");

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ride_name": rideName, "quantity": quantity}),
      );

      print("🔹 Response Body: ${response.body}");

      var responseData = jsonDecode(response.body);
      if (responseData["success"]) {
        print("✅ บันทึกสำเร็จ: ${responseData["message"]}");
      } else {
        print("❌ เกิดข้อผิดพลาด: ${responseData["message"]}");
      }
    } catch (e) {
      print("🚨 Error: $e");
    }
  }

  void confirmPurchase() {
    setState(() {
      rideTicketCounts.forEach((ride, count) {
        if (count > 0) {
          sendRideTicketDataToServer(ride, count);
        }
      });

      // Reset count after purchase
      rideTicketCounts.updateAll((key, value) => 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ซื้อตั๋วเครื่องเล่น")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ...rideTicketCounts.keys.map((ride) => buildRideTicketOption(ride)),
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

  Widget buildRideTicketOption(String ride) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text("ตั๋ว $ride", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text("ราคา ${rideTicketPrices[ride]} บาท", style: TextStyle(fontSize: 16, color: Colors.green)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (rideTicketCounts[ride]! > 0) {
                    rideTicketCounts[ride] = rideTicketCounts[ride]! - 1;
                  }
                });
              },
            ),
            Text(rideTicketCounts[ride].toString(), style: TextStyle(fontSize: 18)),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  rideTicketCounts[ride] = rideTicketCounts[ride]! + 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
