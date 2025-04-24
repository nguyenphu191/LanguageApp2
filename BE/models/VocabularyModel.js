const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const VocabularySchema = new Schema({
  word: {
    type: String,
    required: true
  },
  definition: {
    type: String,
    required: true
  },
  example: {
    type: String,
    required: true
  },
  exampleTranslation: {
    type: String,
    required: true
  },
  difficulty: {
    type: String,
    enum: ['easy', 'medium', 'hard'],
    default: 'medium'
  },
  topicId: {
    type: String,
    required: true
  },
  imageUrl: {
    type: String,
    default: ''
  }
}, { timestamps: true });


module.exports = mongoose.model('Vocabulary', VocabularySchema);