const Notification = require('../models/NotificationModel');
const User = require('../models/UserModel'); // Giả sử bạn có model User
const jwt = require('jsonwebtoken');
exports.createNotification = async (req, res) => {
  try {
    const { recipientId, type, title, content } = req.body;
    
    // Xác thực dữ liệu đầu vào
    if (!recipientId || !title || !content) {
      return res.status(400).json({ message: 'recipientId, title, và content là bắt buộc' });
    }

    // Kiểm tra nếu recipientId không phải "all" thì phải tồn tại user
    if (recipientId !== "all") {
      const userExists = await User.findById(recipientId);
      if (!userExists) {
        return res.status(404).json({ message: 'Người dùng không tồn tại' });
      }
    }

    // Tạo thông báo mới
    const notification = new Notification({
      recipientId,
      type: type || 'general',
      title,
      content,
      time: new Date(),
    });

    await notification.save();
    res.status(201).json({ success: true, data: notification });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi tạo thông báo', error: error.message });
  }
};

exports.getUserNotifications = async (req, res) => {
  
  try {
    const userId = req.user.userId; // Lấy userId từ token đã giải mã
    // Kiểm tra user tồn tại
    const userExists = await User.findById(userId);
    if (!userExists) {
      return res.status(404).json({ message: 'Người dùng không tồn tại' });
    }

    // Lấy thông báo cho user cụ thể và thông báo chung cho tất cả
    const notifications = await Notification.find({
      $or: [
        { recipientId: userId },
        { recipientId: "all" }
      ]
    }).sort({ time: -1 });

    // Chuyển đổi để thêm trường isRead cho từng thông báo
    const formattedNotifications = notifications.map(notification => {
      const notifObj = notification.toObject();
      notifObj.isRead = notification.isReadByUser(userId);
      // Không cần trả về toàn bộ map isRead
      delete notifObj.isRead;
      return {
        ...notifObj,
        isRead: notification.isReadByUser(userId)
      };
    });

    res.status(200).json({ success: true, data: formattedNotifications });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy thông báo', error: error.message });
  }
};

exports.markAsRead = async (req, res) => {
  console.log('Đánh dấu thông báo đã đọc:', req.params); 
  try {
    const { notificationId } = req.params;
    const userId = req.user.userId; // Lấy userId từ token đã giải mã
    
    const notification = await Notification.findById(notificationId);
    if (!notification) {
      return res.status(404).json({ message: 'Thông báo không tồn tại' });
    }

    // Kiểm tra xem người dùng có quyền đọc thông báo này không
    if (notification.recipientId !== "all" && notification.recipientId !== userId) {
      return res.status(403).json({ message: 'Không có quyền truy cập thông báo này' });
    }

    await notification.markAsReadByUser(userId);
    res.status(200).json({ success: true, message: 'Đã đánh dấu thông báo là đã đọc' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi đánh dấu thông báo đã đọc', error: error.message });
  }
};

exports.deleteNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;
    
    const notification = await Notification.findByIdAndDelete(notificationId);
    if (!notification) {
      return res.status(404).json({ message: 'Thông báo không tồn tại' });
    }

    res.status(200).json({ success: true, message: 'Đã xóa thông báo thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi xóa thông báo', error: error.message });
  }
};