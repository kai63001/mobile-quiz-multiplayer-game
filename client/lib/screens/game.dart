import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class StreamSocket {
  final _socketResponse = StreamController();

  void Function(List<dynamic>) get addResponse => _socketResponse.sink.add;

  Stream get getResponse => _socketResponse.stream;

  void dispose() {
    print("close _socketResponse");
    _socketResponse.close();
  }
}

class Game extends StatefulWidget {
  const Game(
      {Key? key,
      required this.code,
      required this.socket,
      required this.username})
      : super(key: key);

  final IO.Socket socket;
  final String code;
  final String username;

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  StreamSocket streamSocket = StreamSocket();

  late String codeRoom;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: Text(
            "GAME",
            style: GoogleFonts.fredokaOne(
              textStyle: TextStyle(color: Colors.white, letterSpacing: .5),
            ),
          ),
          centerTitle: true,
        ),
        body: Text("hello"));
  }
}