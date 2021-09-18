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

class JoinLobby extends StatefulWidget {
  const JoinLobby({Key? key, required this.code, required this.socket})
      : super(key: key);

  final IO.Socket socket;
  final String code;
  @override
  _JoinLobbyState createState() => _JoinLobbyState();
}

class _JoinLobbyState extends State<JoinLobby> {
  StreamSocket streamSocket = StreamSocket();

  @override
  void initState() {
    joinRoom();
    super.initState();
  }

  void joinRoom() {
    print("join room");
    widget.socket.emit("join", widget.code);
    widget.socket.on("join", (data) {
      streamSocket.addResponse(data);
    });
  }

  @override
  void dispose() {
    print("leave");
    widget.socket.emit("leave", widget.code);
    widget.socket.emit("listRooms");
    super.dispose();
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
          "Room : ${widget.code}",
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
                          Map<String, dynamic> data = snapshot.data[index];
                          return Container(
                            margin: EdgeInsets.only(bottom:5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                '${data["username"]}',
                                style: GoogleFonts.fredokaOne(
                                  textStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 20,
                                      letterSpacing: .5),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
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
