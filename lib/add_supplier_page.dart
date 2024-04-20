import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddSupplierPage extends StatefulWidget {
  @override
  _AddSupplierPageState createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final _formKey = GlobalKey<FormState>();
  final _supplierIdController = TextEditingController();
  final _userNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _addressController = TextEditingController();
  String? typeOfGoods;
  final goodsTypes = ['Goods1', 'Goods2', 'Goods3'];

  Future<void> sendData() async {
    var url = Uri.parse(
        'http://192.168.45.246:5009/add_supplier'); // Update with your endpoint
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'supplierId': _supplierIdController.text,
          'userName': _userNameController.text,
          'mobileNumber': _mobileNumberController.text,
          'address': _addressController.text,
          'typeOfGoods': typeOfGoods,
        }));

    print(
        'Sending supplier data to the server...'); // Terminal message before sending the request

    if (response.statusCode == 200) {
      print(
          'New supplier is added. Server response: ${response.body}'); // Terminal message on successful response
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('New supplier is added')));

      // Reset the form fields and the dropdown menu
      _formKey.currentState?.reset();
      _supplierIdController.clear();
      _userNameController.clear();
      _mobileNumberController.clear();
      _addressController.clear();
      setState(() {
        typeOfGoods = null;
      });
    } else {
      print(
          'Failed to add supplier. Status code: ${response.statusCode}'); // Terminal message on failure
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add supplier')));
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    _supplierIdController.dispose();
    _userNameController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Supplier'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _supplierIdController,
                decoration: InputDecoration(labelText: 'Supplier ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter supplier ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'User Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mobileNumberController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField(
                value: typeOfGoods,
                decoration: InputDecoration(labelText: 'Type of Goods'),
                items: goodsTypes.map((String goods) {
                  return DropdownMenuItem(value: goods, child: Text(goods));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    typeOfGoods = value as String?;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select type of goods' : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      sendData();
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
