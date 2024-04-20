import 'package:flutter/material.dart';

import 'mongo_database.dart'; // Make sure this points to your MongoDatabase class

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  Future<List<Map<String, dynamic>>>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = MongoDatabase
        .getAllData(); // Initializes the future when the state is first created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Data Page'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dataFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(child: Text('No data found'));
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen[
                        600], // Darker green for better contrast with white text
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: item.entries.map((entry) {
                            return Text(
                              "${entry.key}: ${entry.value}",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors
                                    .white, // White text color for better readability
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[300]),
                        onPressed: () async {
                          final userId = item['userId'];
                          if (userId != null) {
                            await MongoDatabase.deleteUser(userId);
                            setState(() {
                              _dataFuture = MongoDatabase
                                  .getAllData(); // Refresh the data displayed
                            });
                          } else {
                            // Log the problematic item for debugging
                            print(
                                'Cannot delete item without userId. Item: $item');
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
