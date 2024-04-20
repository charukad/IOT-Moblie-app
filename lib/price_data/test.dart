import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;

import 'constant3.dart'; // Make sure this file contains your MongoDB constants.

class WeeklyExpensesPage extends StatefulWidget {
  @override
  _WeeklyExpensesPageState createState() => _WeeklyExpensesPageState();
}

class _WeeklyExpensesPageState extends State<WeeklyExpensesPage> {
  Future<List<Map<String, dynamic>>> fetchExpensesData() async {
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
        title: Text('Weekly Expenses'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchExpensesData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No expenses data found'));
          }

          final weeklyCostData = processDataForWeeklyCost(snapshot.data!);
          final goodsCostData = processDataForGoodsCost(snapshot.data!);

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total Cost Per Week',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 300, // Adjust the height as needed
                  child: BarChart(BarChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                    barGroups: weeklyCostData,
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Cost Per Type of Goods',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 300, // Adjust the height as needed
                  child: BarChart(BarChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                    barGroups: goodsCostData,
                  )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<BarChartGroupData> processDataForWeeklyCost(
      List<Map<String, dynamic>> rawData) {
    Map<int, double> weeklyCosts = {};

    for (var doc in rawData) {
      final date = DateTime.parse(doc['delivered_date'].toString());
      final weekOfYear = weekNumber(date);
      final totalCost = double.tryParse(doc['total_cost'].toString()) ?? 0.0;

      weeklyCosts.update(weekOfYear, (value) => value + totalCost,
          ifAbsent: () => totalCost);
    }

    return weeklyCosts.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.toDouble(),
        barRods: [
          BarChartRodData(y: entry.value, colors: [Colors.blue])
        ],
      );
    }).toList();
  }

  List<BarChartGroupData> processDataForGoodsCost(
      List<Map<String, dynamic>> rawData) {
    Map<String, double> goodsCosts = {};

    for (var doc in rawData) {
      final typeOfGoods = doc['type_of_goods'].toString();
      final totalCost = double.tryParse(doc['total_cost'].toString()) ?? 0.0;

      goodsCosts.update(typeOfGoods, (value) => value + totalCost,
          ifAbsent: () => totalCost);
    }

    int i = 0;
    return goodsCosts.entries.map((entry) {
      i++;
      return BarChartGroupData(
        x: i.toDouble(),
        barRods: [
          BarChartRodData(y: entry.value, colors: [Colors.green])
        ],
      );
    }).toList();
  }

  int weekNumber(DateTime date) {
    final beginningOfYear = DateTime(date.year, 1, 1, 0, 0);
    final firstMonday = beginningOfYear.weekday;
    final daysInFirstWeek = 8 - firstMonday;
    final diff = date.difference(beginningOfYear);
    var weeks = ((diff.inDays - daysInFirstWeek) / 7).ceil();
    if (daysInFirstWeek >= 4) {
      weeks += 1;
    }
    return weeks;
  }
}

void main() {
  runApp(MaterialApp(home: WeeklyExpensesPage()));
}
