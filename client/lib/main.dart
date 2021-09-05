import 'package:client/reload/reload.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKYCAP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
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
    IO.Socket socket = IO.io('http://10.94.0.51:3000', <String, dynamic>{
      'transports': ['websocket'],
      'forceNew': true
    });
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


  @override
  void dispose() {
    super.dispose();
    print("test");
    socket.disconnect();
  }


  @override
  Widget build(BuildContext context) {
    return ReassembleListener(
      onReassemble: () {  
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("SKYCAP"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
