import 'dart:async';

import 'package:client/screens/join_lobby.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// STEP1:  Stream setup
class StreamSocket {
  final _socketResponse = StreamController();

  void Function(List<dynamic>) get addResponse => _socketResponse.sink.add;

  Stream get getResponse => _socketResponse.stream;

  void dispose() {
    print("close _socketResponse");
    _socketResponse.close();
  }
}

class ListLobby extends StatefulWidget {
  const ListLobby({Key? key, required this.socket}) : super(key: key);

  final IO.Socket socket;

  @override
  _ListLobbyState createState() => _ListLobbyState();
}

class _ListLobbyState extends State<ListLobby> {
  // List rooms = [];

  StreamSocket streamSocket = StreamSocket();
  @override
  void initState() {
    super.initState();
    // widget.socket.emit("listRooms");
    widget.socket.emit("join", "findListRooms");
    getRooms();
  }

  void getRooms() async {
    print("rooms");
    await Future.delayed(Duration(milliseconds: 500));
    print("next");
    widget.socket.emit("listRooms");
    widget.socket.on("listRooms", (data) {
      print("update listdata");
      streamSocket.addResponse(data);
    });
  }

  @override
  void dispose() {
    // rooms.clear();
    // streamSocket.dispose();
    widget.socket.emit("leave", "findListRooms");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(
          "List Rooms",
          style: GoogleFonts.fredokaOne(
            textStyle: TextStyle(color: Colors.white, letterSpacing: .5),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: StreamBuilder(
          stream: streamSocket.getResponse,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print(snapshot.data);
            if (snapshot.hasData && snapshot.data.length > 1) {
              return Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      if (snapshot.data[index].toString() != "findListRooms") {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => JoinLobby(
                                      socket: widget.socket,
                                      code: snapshot.data[index].toString())),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Room : ${snapshot.data[index]}",
                                style: GoogleFonts.fredokaOne(
                                  textStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15,
                                      letterSpacing: .5),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
                ),
              );
            } else {
              return Container(
                child: Center(
                  child: Text(
                    "No Rooms found.",
                    style: GoogleFonts.fredokaOne(
                      textStyle: TextStyle(
                          color: Colors.white, fontSize: 25, letterSpacing: .5),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
