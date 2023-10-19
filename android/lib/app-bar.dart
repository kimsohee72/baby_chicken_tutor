import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';


AppBar appBar(String title, String bleState, BuildContext context, bool back) {

  return AppBar(
    automaticallyImplyLeading: back,
    iconTheme: IconThemeData(color: Color(0xffd9d9d9)),
    backgroundColor: Colors.transparent, //0xffc0c0ff
    toolbarHeight: 50, //36,
    centerTitle: true,
    // leading: Icon(Icons.arrow_back),
    // Here we take the value from the MyHomePage object that was created by
    // the App.build method, and use it to set our appbar title.
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        fontFamily: 'NanumSquareRound',
        color: Colors.black,
      ),
    ),

    elevation: 0, //1.0,
    actions: <Widget>[

      !back ? Container() : bleState == "Connected" ?
      Icon(Icons.link, color: Colors.black26) : Icon(Icons.link_off, color: Colors.black26,),
      !back ? Container() : bleState == "Connected" ?
      TextButton(
        child: Text(
          bleState,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.black26,
          ),
        ),
        onPressed: (){},
      ) : TextButton(
        child: Text(
          bleState,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.black12,
          ),
        ),
        onPressed: (){},
      ),
      IconButton(
        icon: Icon(Icons.close),
        color: Color(0xffd9d9d9),
        tooltip: 'Closes application',
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text("앱을 종료하시겠습니까?"),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () => exit(0),
                        child: Text("종료"),
                    ),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("취소")),
                  ],
                );
              }
          );
        }
      ),
    ],
  );
}

