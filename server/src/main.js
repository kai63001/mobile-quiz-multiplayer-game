const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);


let users = {};

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

function getActiveRooms(io) {
  const arr = Array.from(io.sockets.adapter.rooms);
  const filtered = arr.filter(room => !room[1].has(room[0]))
  const res = filtered.map(i => i[0]);
  return res;
}

io.on('connection', (socket) => {
  // console.log(socket.id);
  console.log('a user connected');
  console.log(io.sockets.adapter.rooms)
  // const data = Array.from(io.sockets.adapter.rooms.keys());

  // save username
  socket.on('send-username', function (username) {
    socket.username = username;
    let id = socket.id;
    let data = {}
    data[id] = {
      username
    }
    users = {
      ...users,
      ...data
    }
    console.log(users)
  });

  // get username
  socket.on('get-username', function (nickname) {
    console.log(users[socket.id]?.username);
  });

  // join room
  socket.on("join", (data) => {
    socket.join(data);
    console.log(`join rooms ${data}`)
    // console.log(getActiveRooms(io))
    console.log(io.sockets.adapter.rooms.get(data))
  })

  socket.on("listRooms", (data) => {
    console.log("listRooms");
    console.log(getActiveRooms(io))
    socket.emit("listRooms", getActiveRooms(io));
    socket.to("findListRooms").emit("listRooms", getActiveRooms(io));
  })

  socket.on("leave", (data) => {
    socket.leave(data);
  })

});



server.listen(3000, () => {
  console.log('listening on *:3000');
});