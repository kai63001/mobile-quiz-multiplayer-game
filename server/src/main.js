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

function getUsernameFormId(io,roomid) {
  console.log("roomid")
  console.log(roomid)
  const arr = Array.from(io.sockets.adapter.rooms.get(roomid) ?? {});
  const username = arr.map((data,i)=>users[data])
  console.log("username")
  console.log(arr)
  return username

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
    if (data != "findListRooms"){
      console.log(getUsernameFormId(io,data))
      socket.emit("join", getUsernameFormId(io,data));
      socket.to(data).emit("join", getUsernameFormId(io,data));
    }

  })

  socket.on("listRooms", (data) => {
    console.log("listRooms");
    socket.emit("listRooms", getActiveRooms(io));
    socket.to("findListRooms").emit("listRooms", getActiveRooms(io));
  })

  socket.on("leave", (data) => {
    socket.leave(data);
    if(data != "findListRooms"){
      socket.to(data).emit("join", getUsernameFormId(io,data));
    }
  })

});



server.listen(3000, () => {
  console.log('listening on *:3000');
});