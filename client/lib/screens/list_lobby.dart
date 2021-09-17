import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// STEP1:  Stream setup
class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

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
      ),
      body: Container(
        child: StreamBuilder(
          stream: streamSocket.getResponse,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print(snapshot.data);
            if (snapshot.hasData) {
              return Container(
                child: Text(snapshot.data.toString()),
              );
            } else {
              return Container(
                child: Text("snapshot.data.toString()"),
              );
            }
          },
        ),
      ),
    );
  }
}
