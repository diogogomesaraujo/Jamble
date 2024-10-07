import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlankScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Blank Screen"),
      ),
      child: Center(
        child: Text(
          "This is a blank screen.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
