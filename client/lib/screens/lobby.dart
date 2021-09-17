import 'package:client/screens/create_lobby.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Lobby extends StatefulWidget {
  const Lobby({Key? key, required this.socket, required this.username})
      : super(key: key);

  final IO.Socket socket;
  final String username;

  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome ${widget.username}.",
              style: GoogleFonts.fredokaOne(
                textStyle: TextStyle(
                    color: Colors.white, fontSize: 25, letterSpacing: .5),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => CreateLobby(
                            socket: widget.socket,
                          )),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'CREATE LOBBY',
                    style: GoogleFonts.fredokaOne(
                      textStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                          letterSpacing: .5),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'JOIN LOBBY',
                  style: GoogleFonts.fredokaOne(
                    textStyle: TextStyle(
                        color: Colors.white, fontSize: 15, letterSpacing: .5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
