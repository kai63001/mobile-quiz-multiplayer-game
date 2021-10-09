const mongoose = require("mongoose");

const QuizSchema = new mongoose.Schema({
  type: {
    type: String,
    required: true,
  },
  quiz: {
    type: String,
    required: true,
  },
  choice: [
    {
      type: String,
      required: true,
    },
  ],
  answer: {
    type: Number,
    required: true,
  },
});

const quiz = mongoose.model("Quiz", QuizSchema);

module.exports = quiz;
