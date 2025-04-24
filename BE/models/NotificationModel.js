const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const NotificationSchema = new Schema({
  recipientId: {
    type: String,
    required: true, // "all" hoặc userId cụ thể
  },
  type: {
    type: String,
    enum: ['general', 'event', 'warning', 'message', 'reminder'],
    default: 'general'
  },
  title: {
    type: String,
    required: true
  },
  content: {
    type: String,
    required: true
  },
  time: {
    type: Date,
    default: Date.now
  },
  isRead: {
    type: Map,
    of: Boolean,
    default: {} // Lưu trạng thái đọc của từng người dùng {userId: boolean}
  }
}, { timestamps: true });

// Phương thức để kiểm tra nếu thông báo đã được đọc bởi người dùng
NotificationSchema.methods.isReadByUser = function(userId) {
  return this.isRead.get(userId) === true;
};

// Phương thức đánh dấu thông báo đã đọc
NotificationSchema.methods.markAsReadByUser = function(userId) {
  this.isRead.set(userId, true);
  return this.save();
};

module.exports = mongoose.model('Notification', NotificationSchema);