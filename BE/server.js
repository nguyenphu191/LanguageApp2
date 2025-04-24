const socketIo = require('socket.io');
const http = require('http');
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const UserRoute = require('./routes/UserRoute');
const NotificationRoute = require('./routes/NotificationRoute');
const cors = require('cors');
const TopicRoute = require('./routes/TopicRoute');
const LanguageRoute = require('./routes/LanguageRoute'); 
const VocabularyRoute = require('./routes/VocabularyRoute');

const path = require('path');

dotenv.config(); // Load biến môi trường từ .env

// Khởi tạo Express
const app = express();

// Middleware
app.use(bodyParser.json());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));  // 🔥 Hỗ trợ form data

// Kết nối MongoDB
mongoose
  .connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('✅ Kết nối MongoDB thành công.'))
  .catch((err) => console.error('❌ Lỗi kết nối MongoDB:', err));

// Khởi tạo server HTTP và Socket.IO
const server = http.createServer(app);
const io = socketIo(server);

// Lưu socket.io vào app để sử dụng trong controller
app.set('io', io);

// Socket.IO connection
io.on('connection', (socket) => {
    console.log('✅ User connected:', socket.id);

    socket.on('join', (userId) => {
        socket.join(userId);
        console.log(`✅ User ${userId} đã tham gia phòng.`);
    });

    socket.on('disconnect', () => {
        console.log('❌ User disconnected:', socket.id);
    });
});
// Cung cấp truy cập tĩnh cho thư mục uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
// Routes
app.use('/api/user', UserRoute);
app.use('/api/noti', NotificationRoute);
app.use('/api/topic', TopicRoute); 
app.use('/api/language', LanguageRoute);
app.use('/api/vocab', VocabularyRoute);


// Start server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`🚀 Server chạy tại cổng ${PORT}.`));
