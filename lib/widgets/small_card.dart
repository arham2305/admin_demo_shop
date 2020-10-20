import 'package:flutter/material.dart';

class SmallCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final int value;
  final Color color1;
  final Color color2;

  SmallCard({
    @required this.icon,
    @required this.title,
    @required this.value,
    @required this.color1,
    @required this.color2,
  });

  @override
  _SmallCardState createState() => _SmallCardState();
}

class _SmallCardState extends State<SmallCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2.0,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  widget.icon,
                  color: Colors.blue,
                  size: 40,
                ),
                SizedBox(width: 5),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.blue,
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            ),
            Text(
              widget.value.toString(),
              style: TextStyle(
                fontSize: 35,
                color: Colors.blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
