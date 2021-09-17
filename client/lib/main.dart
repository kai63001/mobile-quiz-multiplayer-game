import 'package:client/reload/reload.dart';
import 'package:client/screens/lobby.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.red,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKYCAP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IO.Socket socket = IO.io('http://192.168.30.241:3000', <String, dynamic>{
    'transports': ['websocket'],
    'forceNew': true
  });

  final username = TextEditingController();
  @override
  void initState() {
    super.initState();
    start();
  }

  void start() {
    print("run start");

    socket.onConnect((_) {
      print('connect');
    });

    socket.on("listRooms", (data) => print(data));

    socket.onConnectError((data) {
      print(data);
    });

    socket.onDisconnect((_) {
      print('disconnect');
    });
  }

  void startGame() {
    print(username.text);
    if (username.text.length <= 0) {
      final snackBar = SnackBar(
        content: Text(
          'Please enter username',
          style: GoogleFonts.fredokaOne(
            textStyle: TextStyle(color: Colors.white, letterSpacing: .5),
          ),
        ),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return null;
    }
    socket.emit("send-username", username.text);
    Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => Lobby(
                socket: socket,
                username: username.text,
              )),
    );
  }

  @override
  void dispose() {
    username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ReassembleListener(
      onReassemble: () {},
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Enter your name:',
                style: GoogleFonts.fredokaOne(
                  textStyle: TextStyle(
                      color: Colors.white, fontSize: 25, letterSpacing: .5),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: size.width * 0.8,
                child: TextField(
                  controller: username,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredokaOne(
                    textStyle: TextStyle(
                        color: Colors.black, fontSize: 15, letterSpacing: .5),
                  ),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent),
                        // borderRadius: BorderRadius.circular(25.7),
                      ),
                      hintText: 'Username..'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  startGame();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'START GAME',
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
            ],
          ),
        ),
      ),
    );
  }
}
