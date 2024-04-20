import 'package:flutter/material.dart';

import 'add_supplier_page.dart';
import 'camera_page.dart';
import 'overview.dart'; // Import DummyPage
import 'place_item_page.dart'; // Ensure these imports are correct
import 'retrieve_item_page.dart';
import 'storage_page.dart';
import 'supplies_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Text('Home Page'),
    PlaceItemPage(),
    RetrieveItemPage(),
    AddSupplierPage(),
    AddSuppliesPage(),
    StoragePage(),
    CameraPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OPTIMUS Warehouse Solutions'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Overview()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Place'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Retrieve'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_business), label: 'Supplier'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping), label: 'Supplies'),
          BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Storage'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Camera'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
