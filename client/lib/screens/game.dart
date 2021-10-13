import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  var list = new List<int>.generate(20, (i) => i + 1);
  List playerPosition = [];
  List playerPositionX = [];
  List colorPlayerIndex = ["pink", "green", "blue"];
  late String codeRoom;
  late int iAmAt; //player index
  int nowTurn = 0; //turn of player index

  Random rnd = new Random();

  bool gameStarted = false;

  double failPositionY = 50 + 145;

  void initGame() async {
    int lengthOfPlayer = widget.player.length;
    double positionX = MediaQuery.of(context).size.width * 0.5 +
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
        positionX -= 60;
        playerPosition = [
          ...playerPosition,
          {
            "username": widget.player[i]["username"],
            "positionX": positionX,
            "positionY": 50 + 145,
            "color": colorPlayerIndex[i]
          }
        ];
        playerPositionX = [
          ...playerPositionX,
          {
            "positionX": positionX,
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
      nowTurn = 0;
    });
  }

  void _startGame() async {
    setState(() {
      gameStarted = true;
    });
    await Future.delayed(Duration(seconds: 2));
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
                    GestureDetector(
                      onTap: () {
                        int r = 1 + rnd.nextInt(7 - 1);
                        print(r);
                        Navigator.pop(context);
                        Future.delayed(
                            Duration.zero, () => showDice(context, r));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Image.asset(
                          'assets/images/dice.png',
                          color: Colors.white,
                        ),
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

  void showDice(BuildContext context, int nume) async {
    late BuildContext dialogContext;
    showDialog(
        context: context,
        builder: (context) {
          dialogContext = context;
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Image.asset(
                      'assets/images/$nume.png',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      '$nume',
                      style: GoogleFonts.fredokaOne(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            letterSpacing: .5),
                      ),
                      textAlign: TextAlign.center,
                    ),
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
          );
        });
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(dialogContext);
    this._changePosition(nume);
  }

  void _changePosition(int rn) async {
    int positionY = 145 * rn;
    setState(() {
      playerPosition[iAmAt]["positionY"] += positionY;
    });
    // if (nowTurn < playerPosition.length - 1) {
    //   print("linke 241");
    //   setState(() {
    //     nowTurn += 1;
    //   });
    // } else {
    //   print("linke 246");
    //   setState(() {
    //     nowTurn = 0;
    //   });
    // }
    Map<dynamic, Object> data = {
      "playerPosition": playerPosition,
      "nowTurn": nowTurn,
      "room": codeRoom
    };
    widget.socket.emit("playerPosition", data);
    // next show quiz
    await Future.delayed(Duration(seconds: 2));
    this._showTypeOfQuiz();
  }

  void _showTypeOfQuiz() {
    Map<String, dynamic> dataSend = {"room": codeRoom, "iAmAt": iAmAt};
    widget.socket.emit("quiz", dataSend);
    bool dialogShow = false;
    widget.socket.on("quiz", (data) {
      if (mounted == true && dialogShow == false) {
        dialogShow = true;
        showDialog(
            context: context,
            builder: (context) {
              return Scaffold(
                backgroundColor: Theme.of(context).primaryColor,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          'QUESTION TYPE : ${data[0]["type"]}',
                          style: GoogleFonts.fredokaOne(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                letterSpacing: .5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          'Would you like to answer this question?',
                          style: GoogleFonts.fredokaOne(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                letterSpacing: .5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  this._showQuiz(data[0]);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      'YES',
                                      style: GoogleFonts.fredokaOne(
                                        textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            letterSpacing: .5),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  this._iCantAnswer();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      'NO',
                                      style: GoogleFonts.fredokaOne(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            letterSpacing: .5),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
              );
            });
      }
    });
  }

  void _showQuiz(data) async {
    print(data);
    showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Center(
                        child: Container(
                          child: Text(
                            "${data['quiz']}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredokaOne(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  letterSpacing: .5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      for (int i = 0; i < data["choice"].length; i++)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "${data["choice"][i]}",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredokaOne(
                                textStyle: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 20,
                                    letterSpacing: .5),
                              ),
                            ),
                          ),
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
                ],
              ),
            ),
          );
        });
  }

  void _iCantAnswer() {
    setState(() {
      playerPosition[iAmAt]["positionY"] = failPositionY;
    });
    this._nextTurn();
    Map<dynamic, Object> data = {
      "playerPosition": playerPosition,
      "nowTurn": nowTurn,
      "room": codeRoom
    };
    widget.socket.emit("playerPosition", data);
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

  void _nextTurn() {
    if (nowTurn < playerPosition.length - 1) {
      print("linke 241");
      setState(() {
        nowTurn += 1;
      });
    } else {
      print("linke 246");
      setState(() {
        nowTurn = 0;
      });
    }
  }

  void _checkSocketPositon() {
    widget.socket.on("playerPosition", (data) {
      print(data);
      if (mounted == true) {
        if (data["nowTurn"] == iAmAt && data["nowTurn"] != nowTurn) {
          this._startGame();
        }
        setState(() {
          playerPosition = data["playerPosition"];
          nowTurn = data["nowTurn"];
        });
      }
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
    this._checkSocketPositon();
  }

  Color returnColor(String stringColor) {
    Color color = Colors.pink;
    if (stringColor == "green") {
      color = Colors.green;
    }
    if (stringColor == "blue") {
      color = Colors.blue;
    }
    return color;
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
                          playerPosition[i]["positionY"].toString()),
                      left: double.parse(
                          playerPositionX[i]["positionX"].toString()),
                      duration: const Duration(milliseconds: 300),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          color: returnColor(playerPosition[i]["color"]),
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
