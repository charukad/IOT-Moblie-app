import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import '../datahook/mongo_database_sup.dart'; // Your MongoDB database class

class DeliveryStatusChartPage extends StatefulWidget {
  @override
  _DeliveryStatusChartPageState createState() =>
      _DeliveryStatusChartPageState();
}

class _DeliveryStatusChartPageState extends State<DeliveryStatusChartPage> {
  late List<charts.Series<StatusData, String>> _seriesPieData;

  @override
  void initState() {
    super.initState();
    _seriesPieData = [];
    _generateData();
  }

  void _generateData() async {
    var dbData = await MongoDatabase
        .getAllData(); // Ensure this method correctly fetches your data.
    Map<String, int> statusCount = {};

    for (var doc in dbData) {
      String status = doc['delivery_status'] ?? 'Unknown';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    List<StatusData> pieData = statusCount.entries
        .map((entry) => StatusData(entry.key, entry.value))
        .toList();

    setState(() {
      _seriesPieData.add(
        charts.Series<StatusData, String>(
          id: 'DeliveryStatus',
          domainFn: (StatusData status, _) => status.status,
          measureFn: (StatusData status, _) => status.count,
          data: pieData,
          labelAccessorFn: (StatusData row, _) => '${row.status}: ${row.count}',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Status Chart'),
      ),
      body: Center(
        child: _seriesPieData.isNotEmpty
            ? Container(
                // Use a Container to provide a specific height.
                height: 300, // Specify the height of the Container
                child: charts.PieChart(
                  _seriesPieData,
                  animate: true,
                  defaultRenderer: charts.ArcRendererConfig(
                      arcRendererDecorators: [charts.ArcLabelDecorator()]),
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}

class StatusData {
  final String status;
  final int count;

  StatusData(this.status, this.count);
}
