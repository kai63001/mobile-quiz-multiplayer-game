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
      required this.username,
      required this.player})
      : super(key: key);

  final IO.Socket socket;
  final String code;
  final String username;
  final List<dynamic> player;

  @override
  _MyGameState createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  StreamSocket streamSocket = StreamSocket();
  var list = new List<int>.generate(10, (i) => i + 1);
  List listPlayer = [];
  List playerPosition = [];
  List<Color> colorPlayerIndex = [Colors.red, Colors.green, Colors.blue];
  late String codeRoom;
  late int iAmAt;

  void initGame() async {
    int lengthOfPlayer = widget.player.length;
    double positionY = MediaQuery.of(context).size.width * 0.5 +
        (lengthOfPlayer *
            32); // defalut position and calculate with player length
    widget.socket.emit("join", codeRoom);
    widget.socket.on("join", (data) {
      //
    });
    setState(() {
      playerPosition = [];
    });

    for (var i = 0; i < lengthOfPlayer; i++) {
      // check where is my index
      if (widget.username == widget.player[i]["username"]) {
        setState(() {
          iAmAt = i;
        });
      }

      setState(() {
        positionY -= 60;
        playerPosition = [
          ...playerPosition,
          {"positionY": positionY, "color": colorPlayerIndex[i]}
        ];
      });
    }
    print("playerPosition : $playerPosition");
    print("iAmAt : $iAmAt");
  }

  void reGame() {
    print("restartGame");
    print(playerPosition);
    setState(() {
      playerPosition = [];
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      codeRoom = "started_${widget.code}";
    });
    this.initGame();
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
                  Center(
                    child: Container(
                      width: size.width * 0.8,
                      margin: EdgeInsets.all(8),
                      height: 130,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                initGame();
                              },
                              child: Container(
                                decoration: BoxDecoration(color: Colors.green),
                                child: Text("new"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                reGame();
                              },
                              child: Container(
                                decoration: BoxDecoration(color: Colors.red),
                                child: Text("re"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  for (var i in list)
                    Container(
                      margin: EdgeInsets.all(8),
                      height: 130,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: Text(
                        "START GAME ${i}",
                        style: GoogleFonts.fredokaOne(
                          textStyle:
                              TextStyle(color: Colors.black, letterSpacing: .5),
                        ),
                      ),
                    )
                ],
              ),
              for (int i = 0; i < playerPosition.length; i++)
                AnimatedPositioned(
                    top: 50 + (145 * 1),
                    left: playerPosition[i]["positionY"],
                    duration: const Duration(milliseconds: 300),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        color: playerPosition[i]["color"],
                      ),
                    ))
            ],
          ),
        ),
      ),
    );
  }
}
