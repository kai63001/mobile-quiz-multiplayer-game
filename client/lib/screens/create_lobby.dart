import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:random_string/random_string.dart';

class CreateLobby extends StatefulWidget {
  const CreateLobby({Key? key, required this.socket, required this.username})
      : super(key: key);

  final IO.Socket socket;
  final String username;

  @override
  _CreateLobbyState createState() => _CreateLobbyState();
}

class _CreateLobbyState extends State<CreateLobby> {
  late String codeRoom;

  @override
  void initState() {
    super.initState();
    randomCode();
  }

  void randomCode() {
    setState(() {
      codeRoom = randomAlphaNumeric(5);
    });
    print(codeRoom);
    joinRooms();
  }

  void joinRooms() {
    widget.socket.emit("join", codeRoom);
  }

  @override
  void dispose() {
    print("leave");
    widget.socket.emit("leave", codeRoom);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Center(
              child: Text(
                'SkyCap Room',
                style: GoogleFonts.fredokaOne(
                  textStyle: TextStyle(
                      color: Colors.white, fontSize: 25, letterSpacing: .5),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              width: size.width * 0.8,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  '${widget.username}',
                  style: GoogleFonts.fredokaOne(
                    textStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        letterSpacing: .5),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            SizedBox(
              width: size.width * 0.8,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'code : ${codeRoom}',
                        style: GoogleFonts.fredokaOne(
                          textStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              letterSpacing: .5),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
