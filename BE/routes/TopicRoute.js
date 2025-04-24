const express = require('express');
const router = express.Router();
const topicController = require('../controllers/TopicController');
const verifyToken = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const path = require('path');
const fs = require('fs');

// Đảm bảo thư mục uploads/topics tồn tại
const uploadDir = 'uploads/topics/';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Sử dụng middleware upload như với Language nhưng điều chỉnh destination
const topicUpload = upload.fields([{ name: 'image', maxCount: 1 }]);

// Route công khai (không yêu cầu xác thực)
router.get('/', topicController.getAllTopics);
router.get('/:id', topicController.getTopicById);

// Route yêu cầu xác thực (admin)
router.post('/', verifyToken, upload.single('image'), topicController.createTopic);
router.put('/:id', verifyToken, topicUpload, topicController.updateTopic);
router.delete('/:id', verifyToken, topicController.deleteTopic);

module.exports = router;