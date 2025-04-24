// middleware/authMiddleware.js
const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
  // Lấy token từ header Authorization
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ 
      message: 'Không tìm thấy token xác thực', 
      success: false 
    });
  }

  try {
    // Lấy token (bỏ phần "Bearer ")
    const token = authHeader.split(' ')[1];
    
    // Xác thực token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'aabb22@@');
    
    // Thêm thông tin người dùng vào request
    req.user = decoded;
    
    // Chuyển request đến route tiếp theo
    next();
  } catch (error) {
    return res.status(401).json({ 
      message: 'Token không hợp lệ hoặc đã hết hạn', 
      success: false 
    });
  }
};

module.exports = verifyToken;