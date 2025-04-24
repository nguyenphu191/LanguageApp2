const express = require('express');
const router = express.Router();
const vocabularyController = require('../controllers/VocabularyController');
const verifyToken = require('../middleware/authMiddleware');

// Route công khai (không yêu cầu xác thực)
router.get('/', vocabularyController.getAllVocabularies);
router.get('/:id', vocabularyController.getVocabularyById);
router.get('/topic/:topicId', vocabularyController.getVocabulariesByTopic);

// Route yêu cầu xác thực (admin)
router.post('/', verifyToken, vocabularyController.createVocabulary);
router.put('/:id', verifyToken, vocabularyController.updateVocabulary);
router.delete('/:id', verifyToken, vocabularyController.deleteVocabulary);

module.exports = router;