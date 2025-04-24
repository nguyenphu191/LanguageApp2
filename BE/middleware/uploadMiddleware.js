// middleware/uploadMiddleware.js
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Đảm bảo thư mục uploads/images tồn tại
const uploadDir = 'uploads/images';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Cấu hình storage cho multer
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    // Lưu tất cả các file vào thư mục images
    console.log(`Saving file to directory: ${uploadDir}`);
    cb(null, uploadDir);
  },
  filename: function(req, file, cb) {
    // Tạo tên file với prefix phù hợp dựa trên route
    let filePrefix = 'file';
    
    if (req.originalUrl.includes('/topics')) {
      filePrefix = 'topic';
    } else if (req.originalUrl.includes('/languages')) {
      filePrefix = 'language';
    }
    
    // Tạo tên file an toàn với timestamp để tránh trùng lặp
    const filename = `${filePrefix}-${Date.now()}${path.extname(file.originalname)}`;
    console.log(`Generated filename: ${filename}`);
    cb(null, filename);
  }
});

// Kiểm tra loại file
const fileFilter = (req, file, cb) => {
  console.log('File upload attempted:');
  console.log('- Mimetype:', file.mimetype);
  console.log('- Filename:', file.originalname);
  console.log('- Route:', req.originalUrl);
  
  const acceptedMimeTypes = [
    'image/jpeg', 
    'image/png', 
    'image/gif', 
    'image/webp',
    'application/octet-stream' // Hỗ trợ Flutter image_picker
  ];
  
  // Kiểm tra MIME type hoặc phần mở rộng file
  const fileExt = path.extname(file.originalname).toLowerCase();
  const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
  
  if (acceptedMimeTypes.includes(file.mimetype) || 
      (file.mimetype === 'application/octet-stream' && validExtensions.includes(fileExt))) {
    console.log('File accepted');
    cb(null, true);
  } else {
    console.log('File rejected - not an accepted image type');
    cb(new Error(`Chỉ chấp nhận file hình ảnh! Nhận được: ${file.mimetype}`), false);
  }
};

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // giới hạn 5MB
  fileFilter: fileFilter
});

module.exports = upload;