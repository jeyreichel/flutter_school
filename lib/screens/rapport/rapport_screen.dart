import 'package:caisse_tectille/services/db/cart_service.dart';
import 'package:caisse_tectille/services/db/cetegory_service.dart';
import 'package:caisse_tectille/services/db/order_services.dart';
import 'package:caisse_tectille/services/db/product_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'models/chart_data.dart';

class StockEntryReportPage extends StatefulWidget {
  const StockEntryReportPage({super.key});

  @override
  State<StockEntryReportPage> createState() => _StockEntryReportPageState();
}

class _StockEntryReportPageState extends State<StockEntryReportPage> {
  late List<ChartData> _chart1 = [];
  late List<ChartData> _chart2 = [];
  late List<ChartData> _chart3 = [];
  bool _isLoading = true;

  final categoryService = CategoryService();
  final productService = ProductService();
  final ordersService = OrderService();
  final cartService = CartService();

  Future<void> _getData() async {
    // names of categories have to be unique here
    final List<String> categories = await categoryService.getNames();
    final List products = await productService.getProducts();

    // Chart 1
    final List<ChartData> chart1 = [];
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      final categoryProducts = products
          .where((p) =>
              p['category'].toString().toLowerCase() == category.toLowerCase())
          .length;
      chart1.add(ChartData(category, categoryProducts));
    }

    // Chart 2
    final List<ChartData> chart2 = [];
    final dates = await ordersService.getDates();
    dates.sort((a, b) => a.compareTo(b));
    final Map<String, int> m = {};
    for (var i = 0; i < dates.length; i++) {
      final date = dates[i];
      if (m[date] != null) {
        m[date] = m[date]! + 1;
      } else {
        m[date] = 1;
      }
    }
    m.forEach(
      (key, value) {
        chart2.add(ChartData(key, value));
      },
    );

    // Chart 3
    final List<ChartData> chart3 = [];
    final carts = await cartService.getItems();
    for (var i = 0; i < carts.length; i++) {
      var products = 0;
      final cart = carts[i];
      final orders = List.from(cart['orders']);
      if (orders.isNotEmpty) {
        for (var i = 0; i < orders.length; i++) {
          products += 1;
        }
      }
      if (products > 0) {
        chart3.add(ChartData(cart['id'].toString(), products));
      }
    }

    setState(() {
      _chart1 = chart1;
      _chart2 = chart2;
      _chart3 = chart3;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: const Text('Rapport des Entrées de Stock'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    SfCartesianChart(
                        title: const ChartTitle(
                            text: 'Ventes par produit par catégorie',
                            backgroundColor: Colors.grey,
                            borderColor: Colors.blue,
                            borderWidth: 2,
                            // Aligns the chart title to left
                            alignment: ChartAlignment.near,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            )),
                        // Initialize category axis
                        primaryXAxis: CategoryAxis(),
                        series: <CartesianSeries<ChartData, String>>[
                          // Renders column chart
                          ColumnSeries<ChartData, String>(
                              dataSource: _chart1,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y)
                        ]),
                    SfCartesianChart(
                        title: const ChartTitle(
                            text: 'Nombre des commandes par jour',
                            backgroundColor: Colors.grey,
                            borderColor: Colors.blue,
                            borderWidth: 2,
                            // Aligns the chart title to left
                            alignment: ChartAlignment.near,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            )),
                        // Initialize category axis
                        primaryXAxis: const CategoryAxis(),
                        series: <CartesianSeries>[
                          LineSeries<ChartData, String>(
                              dataSource: _chart2,
                              // Dash values for line
                              dashArray: <double>[5, 5],
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y)
                        ]),
                    SfCircularChart(
                        title: const ChartTitle(
                            text: 'Chiffres par produit par caissier',
                            backgroundColor: Colors.grey,
                            borderColor: Colors.blue,
                            borderWidth: 2,
                            // Aligns the chart title to left
                            alignment: ChartAlignment.near,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            )),
                        // Initialize category axis
                        series: <CircularSeries>[
                          // Render pie chart
                          PieSeries<ChartData, String>(
                              dataSource: _chart3,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              dataLabelMapper: (ChartData data, _) =>
                                  "Cassier[${data.x}]: ${data.y}",
                              dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  // Avoid labels intersection
                                  labelIntersectAction:
                                      LabelIntersectAction.shift,
                                  labelPosition: ChartDataLabelPosition.outside,
                                  connectorLineSettings: ConnectorLineSettings(
                                      type: ConnectorType.curve,
                                      length: '25%'))),
                        ]),
                  ],
                )));
  }
}
