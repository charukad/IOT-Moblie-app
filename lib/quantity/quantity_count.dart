import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;

import 'constant2.dart'; // Ensure this file contains your MongoDB constants.

class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  Future<List<Map<String, dynamic>>> fetchData() async {
    var db = await mongo_dart.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(COLLECTION_NAME);
    final data = await collection.find().toList();
    await db.close();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Charts'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              final quantityCount =
                  int.tryParse(item['quantity_count'].toString()) ?? 0;
              final storedItemCount =
                  int.tryParse(item['stored_item_count'].toString()) ?? 0;
              final suppliesId = item['supplies_id'].toString();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Supplies ID: $suppliesId', // This is the label for each chart.
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200, // Adjust the height as needed.
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.redAccent,
                                value: quantityCount.toDouble(),
                                title: 'Quantity',
                                radius: 50,
                                titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xffffffff),
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.green,
                                value: storedItemCount.toDouble(),
                                title: 'Stored',
                                radius: 50,
                                titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xffffffff),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: DataPage()));
}
