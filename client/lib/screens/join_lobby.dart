import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class JoinLobby extends StatefulWidget {
  const JoinLobby({Key? key, required this.code, required this.socket})
      : super(key: key);

  final IO.Socket socket;
  final String code;
  @override
  _JoinLobbyState createState() => _JoinLobbyState();
}

class _JoinLobbyState extends State<JoinLobby> {
  @override
  void initState() {
    joinRoom();
    super.initState();
  }

  void joinRoom() {
    print("join room");
    widget.socket.emit("join", widget.code);
    widget.socket.on("join", (data) {
      print("join data");
      print(data);
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
        child: Text("romeo"),
      ),
    );
  }
}
