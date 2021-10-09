const quiz = require("./modules/quiz");
const db = require("./db/mongo");
db;

const mockUpdata = async () => {
  const data = {
    type: "COMPUTER",
    quiz: "test",
    choice: ["romeo", "lnwza"],
    answer: 0,
  };
  const res = await quiz.create(data);
  console.log(res);
  return;
};

mockUpdata();
