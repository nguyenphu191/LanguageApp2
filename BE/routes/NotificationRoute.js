const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/NotificationController');
const verifyToken = require('../middleware/authMiddleware'); // Sửa đường dẫn đến middleware

// Tạo thông báo mới (yêu cầu quyền admin)
router.post('/', verifyToken, notificationController.createNotification);

// Lấy tất cả thông báo cho một người dùng
router.get('/user', verifyToken, notificationController.getUserNotifications);

// Đánh dấu thông báo đã đọc
router.put('/:notificationId/read', verifyToken, notificationController.markAsRead);

// Xóa thông báo (yêu cầu quyền admin)
router.delete('/:notificationId', verifyToken, notificationController.deleteNotification);

module.exports = router;