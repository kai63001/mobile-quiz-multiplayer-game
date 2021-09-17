import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Lobby extends StatefulWidget {
  const Lobby({Key? key, required this.socket}) : super(key: key);

  final IO.Socket socket;

  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Container(
          child: GestureDetector(
              onTap: () {
                print("send");
                widget.socket.emit('get-username', 'test');
              },
              child: Text("romeoo")),
        ),
      ),
    );
  }
}
