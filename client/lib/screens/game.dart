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
  List<Color> colorPlayerIndex = [Colors.pink, Colors.green, Colors.blue];
  late String codeRoom;
  late int iAmAt; //player index
  int nowTurn = 0; //turn of player index

  bool gameStarted = false;

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
          {
            "username": widget.player[i]["username"],
            "positionY": positionY,
            "positionX": 50 + 145,
            "color": colorPlayerIndex[i]
          }
        ];
      });
    }
    print("playerPosition : $playerPosition");
    print("iAmAt : $iAmAt");
    this._startGame();
  }

  void reGame() {
    print("restartGame");
    print(playerPosition);
    setState(() {
      playerPosition = [];
      gameStarted = false;
    });
  }

  void _startGame() async {
    setState(() {
      gameStarted = true;
    });
    await Future.delayed(Duration(seconds: 1));
    if (nowTurn == iAmAt) {
      print("your turn");

      Future.delayed(Duration.zero, () => showRandom(context));
    }
  }

  void showRandom(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        'TAP THE DICE TO RANDOM',
                        style: GoogleFonts.fredokaOne(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              letterSpacing: .5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Image.asset(
                        'assets/images/dice.png',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text("romsseo")),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  String _checkTurnStatus() {
    String text = "";
    if (nowTurn == iAmAt) {
      text = "YOUR TURN";
    } else {
      text =
          "${playerPosition[nowTurn]['username'].toString().toUpperCase()} TURN";
    }
    return text;
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
    if (gameStarted == true) {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: Text(
            "${_checkTurnStatus().toString()}",
            style: GoogleFonts.fredokaOne(
              textStyle: TextStyle(color: Colors.white, letterSpacing: .5),
            ),
          ),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.search,
                    size: 26.0,
                  ),
                )),
          ],
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
                                  decoration:
                                      BoxDecoration(color: Colors.green),
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
                            textStyle: TextStyle(
                                color: Colors.black, letterSpacing: .5),
                          ),
                        ),
                      )
                  ],
                ),
                for (int i = 0; i < playerPosition.length; i++)
                  AnimatedPositioned(
                      top: double.parse(
                          playerPosition[i]["positionX"].toString()),
                      left: playerPosition[i]["positionY"],
                      duration: const Duration(milliseconds: 300),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          color: playerPosition[i]["color"],
                        ),
                      )),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: Text(
            "LOADING",
            style: GoogleFonts.fredokaOne(
              textStyle: TextStyle(color: Colors.white, letterSpacing: .5),
            ),
          ),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.search,
                    size: 26.0,
                  ),
                )),
          ],
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
              child: Center(
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
          ))),
        ),
      );
    }
  }
}
