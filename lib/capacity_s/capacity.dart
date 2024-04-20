import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;

import 'constant3.dart'; // Ensure this file contains MONGO_URL and COLLECTION_NAME

class ShelfItem {
  final String shelfNumber;
  final String itemNumber;
  final int state; // 0 for blue, 1 for green

  ShelfItem(
      {required this.shelfNumber,
      required this.itemNumber,
      required this.state});
}

class ShelfItemsPage extends StatefulWidget {
  @override
  _ShelfItemsPageState createState() => _ShelfItemsPageState();
}

class _ShelfItemsPageState extends State<ShelfItemsPage> {
  late Future<List<ShelfItem>> itemsFuture;

  @override
  void initState() {
    super.initState();
    itemsFuture = fetchItemsFromDatabase();
  }

  Future<List<ShelfItem>> fetchItemsFromDatabase() async {
    try {
      var db = await mongo_dart.Db.create(MONGO_URL);
      await db.open();
      var collection = db.collection(COLLECTION_NAME);
      final itemsData = await collection.find().toList();
      await db.close();

      return itemsData.map((item) {
        final shelfNumber = item['shelf_number'].toString();
        final itemNumber = item['item_number'].toString();

        var state = item['state'];
        if (state is! int) {
          print(
              "Invalid state value for item $itemNumber on shelf $shelfNumber. Defaulting to 0.");
          state = 0;
        }

        return ShelfItem(
            shelfNumber: shelfNumber, itemNumber: itemNumber, state: state);
      }).toList();
    } catch (e) {
      print('Error connecting to the database: $e');
      return []; // Ensure a list is always returned
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shelf Items'),
      ),
      body: FutureBuilder<List<ShelfItem>>(
        future: itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Failed to load data'));
          }

          final items = snapshot.data!;
          final blueCount = items.where((item) => item.state == 0).length;
          final greenCount = items.length - blueCount;

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  item.state == 0 ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              item.itemNumber == "0" ? "" : item.itemNumber,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Shelf: ${item.shelfNumber}'),
                      ],
                    );
                  },
                ),
              ),
              Container(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.red,
                        value: blueCount.toDouble(),
                        title:
                            '${((blueCount / items.length) * 100).toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xffffffff)),
                      ),
                      PieChartSectionData(
                        color: Colors.green,
                        value: greenCount.toDouble(),
                        title:
                            '${((greenCount / items.length) * 100).toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xffffffff)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ShelfItemsPage()));
}
