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

class MyGame extends StatefulWidget {
  const MyGame(
      {Key? key,
      required this.code,
      required this.socket,
      required this.username})
      : super(key: key);

  final IO.Socket socket;
  final String code;
  final String username;

  @override
  _MyGameState createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  StreamSocket streamSocket = StreamSocket();
  var list = new List<int>.generate(10, (i) => i + 1);
  List playerPosition = [];
  late String codeRoom;

  void initGame() {
    print(codeRoom);
    print("code room :$codeRoom");
    widget.socket.emit("join", codeRoom);
    widget.socket.on("join", (data) {
      print("join");
      print(data);
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      codeRoom = "started_${widget.code}";
    });
    initGame();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  for (var i in list)
                    Container(
                      margin: EdgeInsets.all(8),
                      height: 130,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: GestureDetector(
                        onTap: () {
                          widget.socket.emit("join", codeRoom);
                        },
                        child: Text(
                          "START GAME",
                          style: GoogleFonts.fredokaOne(
                            textStyle: TextStyle(
                                color: Colors.black, letterSpacing: .5),
                          ),
                        ),
                      ),
                    )
                ],
              ),
              AnimatedPositioned(
                  top: 50 + (145 * 2),
                  left: size.width * 0.5 - 55,
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.red,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
