const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);

//redis
const redis = require('redis')
const redisClient = redis.createClient()
const { promisify } = require('es6-promisify')
const asyncGet = promisify(redisClient.HGET).bind(redisClient)



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

async function getUsernameFormId(io, roomid) {

  const arr = Array.from(io.sockets.adapter.rooms.get(roomid) ?? {});
  const username = arr.map(async (data, i) => {
    return {"username": await asyncGet(data.toString(),"username")};
  })
  const userdata = await Promise.all(username)
  console.log(userdata)
  return Promise.all(username)

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

    redisClient.hset(id, "username",username)

  });

  // get username
  socket.on('get-username', function (nickname) {
    console.log(users[socket.id]?.username);
  });

  // join room
  socket.on("join", (data) => {
    socket.join(data);
    console.log(`join rooms ${data}`)
    if (data != "findListRooms") {
      console.log(getUsernameFormId(io, data))
      getUsernameFormId(io, data).then(res => {
        socket.emit("join", res);
        socket.to(data).emit("join", res);
      })
    }

  })

  socket.on("listRooms", (data) => {
    console.log("listRooms");
    socket.emit("listRooms", getActiveRooms(io));
    socket.to("findListRooms").emit("listRooms", getActiveRooms(io));
  })

  socket.on("leave", (data) => {
    socket.leave(data);
    if (data != "findListRooms") {
      getUsernameFormId(io, data).then(res => {
        socket.to(data).emit("join", res);
      })
    }
  })

});



server.listen(3000, () => {
  console.log('listening on *:3000');
});