const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});


io.on('connection', (socket) => {
  // console.log(socket.id);
  console.log('a user connected');
  console.log(io.sockets.adapter.rooms)
  const data = Array.from(io.sockets.adapter.rooms.keys());
  socket.emit("listRooms", data);
});


server.listen(3000, () => {
  console.log('listening on *:3000');
});