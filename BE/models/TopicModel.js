const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const TopicSchema = new Schema({
  topic: {
    type: String,
    required: true
  },
  imageUrl: {
    type: String,
    required: true
  },
  numbervocabulary: {
    type: Number,
    default: 0
  },
  languageId: {
    type: String,
    required: true
  },
  level: {
    type: String,
    required: true,
    enum: ['beginner', 'intermediate', 'advanced', 'expert']
  }
}, { timestamps: true });

module.exports = mongoose.model('Topic', TopicSchema);