import 'package:admin_demo_shop/models/task.dart';
import 'package:admin_demo_shop/widgets/small_card.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    Key key,
    @required List<charts.Series<Task, String>> seriesPieData,
  })  : _seriesPieData = seriesPieData,
        super(key: key);

  final List<charts.Series<Task, String>> _seriesPieData;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: 'Revenue\n',
                    style: TextStyle(fontSize: 35, color: Colors.grey)),
                TextSpan(
                    text: '\$1287.99',
                    style: TextStyle(
                        fontSize: 55,
                        color: Colors.black,
                        fontWeight: FontWeight.w300)),
              ]),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SmallCard(
                color2: Colors.indigo,
                color1: Colors.blue,
                icon: Icons.person_outline,
                value: 1265,
                title: 'Users',
              ),
              SmallCard(
                color2: Colors.indigo,
                color1: Colors.blue,
                icon: Icons.shopping_cart,
                value: 30,
                title: 'Orders',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SmallCard(
                color2: Colors.black87,
                color1: Colors.black87,
                icon: Icons.attach_money,
                value: 65,
                title: 'Sales',
              ),
              SmallCard(
                color2: Colors.black,
                color1: Colors.black87,
                icon: Icons.shopping_basket,
                value: 230,
                title: 'Stock',
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Sales per category',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[400],
                          offset: Offset(1.0, 1.0),
                          blurRadius: 4)
                    ]),
                width: MediaQuery.of(context).size.width / 1.2,
                child: ListTile(
                  title: charts.PieChart(_seriesPieData,
                      animate: true,
                      animationDuration: Duration(seconds: 3),
                      behaviors: [
                        new charts.DatumLegend(
                          outsideJustification:
                              charts.OutsideJustification.endDrawArea,
                          horizontalFirst: false,
                          desiredMaxRows: 2,
                          cellPadding:
                              new EdgeInsets.only(right: 4.0, bottom: 4.0),
                        )
                      ],
                      defaultRenderer: new charts.ArcRendererConfig(
                          arcWidth: 30,
                          arcRendererDecorators: [
                            new charts.ArcLabelDecorator(
                                labelPosition: charts.ArcLabelPosition.inside)
                          ])),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
