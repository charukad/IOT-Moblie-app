import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RetrieveItemPage extends StatefulWidget {
  @override
  _RetrieveItemPageState createState() => _RetrieveItemPageState();
}

class _RetrieveItemPageState extends State<RetrieveItemPage> {
  int? selectedItemNumber; // This will hold the selected item number

  Future<void> sendData() async {
    if (selectedItemNumber == null) {
      print(
          'No item number selected.'); // Terminal message when no item number is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an item number first.')),
      );
      return;
    }

    print(
        'Sending item number $selectedItemNumber to the server...'); // Terminal message before sending the request

    var url = Uri.parse('http://192.168.45.246:5009/retrieve_item_data');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'itemNumber': selectedItemNumber, // Send the selected item number
        }));

    if (response.statusCode == 200) {
      print(
          'Data sent successfully. Server response: ${response.body}'); // Terminal message on successful response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your item is retrieving')),
      );
      // Reset the dropdown menu
      setState(() {
        selectedItemNumber = null;
      });
    } else {
      print(
          'Failed to send data. Status code: ${response.statusCode}'); // Terminal message on failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send data from Retrieve Item Page')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Retrieve Item'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<int>(
              value: selectedItemNumber,
              hint: Text('Select Item Number'),
              items: List.generate(20, (index) => index + 1).map((number) {
                return DropdownMenuItem<int>(
                  value: number,
                  child: Text(number.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedItemNumber = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendData,
              child: Text('Retrieve The Item '),
            ),
          ],
        ),
      ),
    );
  }
}
