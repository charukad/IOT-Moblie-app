import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlaceItemPage extends StatefulWidget {
  @override
  _PlaceItemPageState createState() => _PlaceItemPageState();
}

class _PlaceItemPageState extends State<PlaceItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNumberController = TextEditingController();
  final TextEditingController _suppliesIdController = TextEditingController();
  int? _selectedShelfNumber;

  Future<void> sendData() async {
    if (_selectedShelfNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a shelf number')));
      return;
    }

    var url = Uri.parse(
        'http://192.168.45.246:5009/place_item'); // Update with your endpoint
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'itemNumber': _itemNumberController.text,
          'suppliesId': _suppliesIdController.text,
          'shelfNumber': _selectedShelfNumber,
        }));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Item placed successfully')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to place item')));
    }
  }

  @override
  void dispose() {
    _itemNumberController.dispose();
    _suppliesIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Item'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _itemNumberController,
                decoration: InputDecoration(labelText: 'Item Number'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter item number' : null,
              ),
              TextFormField(
                controller: _suppliesIdController,
                decoration: InputDecoration(labelText: 'Supplies ID'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter supplies ID' : null,
              ),
              DropdownButtonFormField<int>(
                value: _selectedShelfNumber,
                decoration: InputDecoration(labelText: 'Shelf Number'),
                items: List.generate(20, (index) => index + 1).map((number) {
                  return DropdownMenuItem<int>(
                    value: number,
                    child: Text(number.toString()),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedShelfNumber = value),
                validator: (value) =>
                    value == null ? 'Please select a shelf number' : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      sendData();
                    }
                  },
                  child: Text('Place Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
