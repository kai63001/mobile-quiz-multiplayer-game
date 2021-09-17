import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CreateLobby extends StatefulWidget {
  const CreateLobby({Key? key, required this.socket}) : super(key: key);

  final IO.Socket socket;

  @override
  _CreateLobbyState createState() => _CreateLobbyState();
}

class _CreateLobbyState extends State<CreateLobby> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Center(child: Text("Create")),
          ],
        ),
      ),
    );
  }
}
