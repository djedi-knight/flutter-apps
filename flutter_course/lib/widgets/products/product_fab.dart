import 'package:flutter/material.dart';

class ProductFAB extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductFABState();
  }
}

class _ProductFABState extends State<ProductFAB> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: FloatingActionButton(
            heroTag: 'contact',
            mini: true,
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(
              Icons.mail,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {},
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: FloatingActionButton(
            heroTag: 'favourite',
            mini: true,
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            onPressed: () {},
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          child: FloatingActionButton(
            heroTag: 'options',
            child: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
