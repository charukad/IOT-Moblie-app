import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;

import 'constant3.dart'; // Ensure this file contains your MongoDB constants.

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
                buildWeeklyCostChart(weeklyCostData),
                buildGoodsCostChart(goodsCostData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildWeeklyCostChart(List<BarChartGroupData> weeklyCostData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Total Cost Per Week',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 200,
          child: BarChart(BarChartData(
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: getLeftSideTitles(),
              ),
              bottomTitles: AxisTitles(
                sideTitles: getBottomWeekSideTitles(weeklyCostData),
              ),
            ),
            barGroups: weeklyCostData,
          )),
        ),
      ],
    );
  }

  Widget buildGoodsCostChart(List<BarChartGroupData> goodsCostData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Cost Per Type of Goods',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 200,
          child: BarChart(BarChartData(
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: getLeftSideTitles(),
              ),
              bottomTitles: AxisTitles(
                sideTitles: getBottomGoodsSideTitles(goodsCostData),
              ),
            ),
            barGroups: goodsCostData,
          )),
        ),
      ],
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
        x: entry.key,
        barRods: [BarChartRodData(toY: entry.value, color: Colors.blue)],
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
      return BarChartGroupData(
        x: i++,
        barRods: [BarChartRodData(toY: entry.value, color: Colors.green)],
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

  SideTitles getBottomWeekSideTitles(List<BarChartGroupData> weeklyCostData) {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (double value, TitleMeta meta) {
        return Text('Week ${value.toInt()}');
      },
      interval: 1,
    );
  }

  SideTitles getBottomGoodsSideTitles(List<BarChartGroupData> goodsCostData) {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (double value, TitleMeta meta) {
        return Text(goodsCostData[value.toInt()].x.toString());
      },
      interval: 1,
    );
  }

  SideTitles getLeftSideTitles() {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (double value, TitleMeta meta) {
        return Text('\$${value.toInt()}');
      },
      interval: 1,
    );
  }
}

void main() {
  runApp(MaterialApp(home: WeeklyExpensesPage()));
}
