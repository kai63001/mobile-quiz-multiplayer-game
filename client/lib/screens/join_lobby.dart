import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_string/random_string.dart';
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

class JoinLobby extends StatefulWidget {
  const JoinLobby(
      {Key? key,
      required this.code,
      required this.socket,
      required this.username})
      : super(key: key);

  final IO.Socket socket;
  final String code;
  final String username;
  @override
  _JoinLobbyState createState() => _JoinLobbyState();
}

class _JoinLobbyState extends State<JoinLobby> {
  StreamSocket streamSocket = StreamSocket();
  late String codeRoom;
  @override
  void initState() {
    randomCode();
    joinRoom();
    super.initState();
  }

  void randomCode() {
    setState(() {
      codeRoom = widget.code;
    });
    if (codeRoom.length < 1) {
      setState(() {
        codeRoom = randomAlphaNumeric(5);
      });
    }
  }

  void joinRoom() {
    print("join room");
    widget.socket.emit("join", codeRoom);
    widget.socket.on("join", (data) {
      print("join");
      print(data);
      streamSocket.addResponse(data);
    });
  }

  @override
  void dispose() {
    print("leave");
    widget.socket.emit("leave", codeRoom);
    widget.socket.emit("listRooms");
    super.dispose();
  }

  void startGame(data) {
    if(data.length <= 1){
      print("start ha pong");
      return null;
    }
    print("start game");
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
          "Room : ${codeRoom}",
          style: GoogleFonts.fredokaOne(
            textStyle: TextStyle(color: Colors.white, letterSpacing: .5),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: StreamBuilder(
          stream: streamSocket.getResponse,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Text(
                      'SkyCap Room',
                      style: GoogleFonts.fredokaOne(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            letterSpacing: .5),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    width: size.width * 0.8,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          print(snapshot.data);
                          Map<String, dynamic> data = (snapshot.data[index]);
                          return Container(
                            margin: EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${data["username"]} ${data["username"] == widget.username ? '(you)' : ''}',
                                    style: GoogleFonts.fredokaOne(
                                      textStyle: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 20,
                                          letterSpacing: .5),
                                    ),
                                  ),
                                  data["host"]
                                      ? Icon(FontAwesomeIcons.chessKing)
                                      : Text(""),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  snapshot.data[0]["username"] == widget.username &&
                          snapshot.data[0]["host"] == true
                      ? GestureDetector(
                        onTap: (){
                          startGame(snapshot.data);
                        },
                        child: Container(
                            width: size.width * 0.8,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Center(
                                child: Text(
                                  'START GAME',
                                  style: GoogleFonts.fredokaOne(
                                    textStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20,
                                        letterSpacing: .5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      )
                      : Text("")
                ],
              );
            } else {
              return Text(
                "Loading",
                style: GoogleFonts.fredokaOne(
                  textStyle: TextStyle(color: Colors.white, letterSpacing: .5),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
