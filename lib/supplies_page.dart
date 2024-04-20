import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting

class AddSuppliesPage extends StatefulWidget {
  @override
  _AddSuppliesPageState createState() => _AddSuppliesPageState();
}

class _AddSuppliesPageState extends State<AddSuppliesPage> {
  final _formKey = GlobalKey<FormState>();
  final _supplierIdController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _suppliesIdController =
      TextEditingController(); // Controller for suppliesId
  String? typeOfGoods;
  DateTime? estimatedDeliveryDate;
  DateTime? deliveredDate;
  final goodsTypes = ['Goods 1', 'Goods 2', 'Goods 3'];

  Future<void> sendData() async {
    String deliveryStatus = estimatedDeliveryDate != null &&
            deliveredDate != null &&
            deliveredDate!.isAfter(estimatedDeliveryDate!)
        ? "Late Delivery"
        : "On Time";

    var url = Uri.parse(
        'http://192.168.45.246:5009/add_supplies'); // Update with your endpoint
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'supplierId': _supplierIdController.text,
          'quantityCount': _quantityController.text,
          'unitCost': _unitCostController.text,
          'totalCost': _totalCostController.text,
          'typeOfGoods': typeOfGoods,
          'estimatedDeliveryDate': estimatedDeliveryDate != null
              ? DateFormat('yyyy-MM-dd').format(estimatedDeliveryDate!)
              : null,
          'deliveredDate': deliveredDate != null
              ? DateFormat('yyyy-MM-dd').format(deliveredDate!)
              : null,
          'deliveryStatus': deliveryStatus,
          'suppliesId':
              _suppliesIdController.text, // Include suppliesId in the payload
        }));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('New supplies added')));
      _formKey.currentState?.reset();
      _supplierIdController.clear();
      _quantityController.clear();
      _unitCostController.clear();
      _totalCostController.clear();
      _suppliesIdController.clear(); // Clear the suppliesId field
      setState(() {
        typeOfGoods = null;
        estimatedDeliveryDate = null;
        deliveredDate = null;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add supplies')));
    }
  }

  @override
  void dispose() {
    _supplierIdController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _totalCostController.dispose();
    _suppliesIdController.dispose(); // Dispose the suppliesId controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Supplies'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _supplierIdController,
                decoration: InputDecoration(labelText: 'Supplier ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Supplier ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity Count'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Quantity Count';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _unitCostController,
                decoration: InputDecoration(labelText: 'Unit Cost'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Unit Cost';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _totalCostController,
                decoration: InputDecoration(labelText: 'Total Cost'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Total Cost';
                  }
                  return null;
                },
              ),
              TextFormField(
                // New TextFormField for suppliesId
                controller: _suppliesIdController,
                decoration: InputDecoration(labelText: 'Supplies ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Supplies ID';
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
              ListTile(
                title: Text(
                    'Estimated Delivery Date: ${estimatedDeliveryDate != null ? DateFormat('yyyy-MM-dd').format(estimatedDeliveryDate!) : 'Select Date'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: estimatedDeliveryDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != estimatedDeliveryDate) {
                    setState(() {
                      estimatedDeliveryDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: Text(
                    'Delivered Date: ${deliveredDate != null ? DateFormat('yyyy-MM-dd').format(deliveredDate!) : 'Select Date'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: deliveredDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != deliveredDate) {
                    setState(() {
                      deliveredDate = picked;
                    });
                  }
                },
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
