const express = require('express');
const router = express.Router();
const languageController = require('../controllers/LanguageController');
const verifyToken = require('../middleware/authMiddleware');

// Đảm bảo có upload middleware
const upload = require('../middleware/uploadMiddleware');

// Route công khai (không yêu cầu xác thực)
router.get('/', languageController.getAllLanguages);
router.get('/:id', languageController.getLanguageById);
router.get('/code/:code', languageController.getLanguageByCode);

// Route yêu cầu xác thực (admin)
router.post('/', verifyToken, upload.single('image'), languageController.createLanguage);
router.put('/:id', verifyToken, upload.single('image'), languageController.updateLanguage);
router.delete('/:id', verifyToken, languageController.deleteLanguage);

module.exports = router;