const express = require('express');
const router = express.Router();
const UserController = require('../controllers/UserController');
const verifyToken = require('../middleware/authMiddleware');
router.post('/login', UserController.login);

router.post('/register', UserController.register);
router.get('/profile', verifyToken, UserController.getUserProfile);
router.put('/profile', verifyToken, UserController.updateUserProfile);
module.exports = router;