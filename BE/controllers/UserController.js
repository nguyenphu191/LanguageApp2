const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
    const { email, password } = req.body;
    const UserModel = require('../models/UserModel');
    try {
        // Tìm người dùng theo email
        const user = await UserModel.findOne({ email });
        if (!user) {
            return res.status(401).json({ 
                message: 'Email không tồn tại',
                success: false
            });
        }

        // So sánh mật khẩu
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ 
                message: 'Mật khẩu không đúng',
                success: false
            });
        }

        // Tạo JWT token
        const token = jwt.sign(
            { userId: user._id, email: user.email },
            process.env.JWT_SECRET || 'aabb22@@',
            { expiresIn: '1h' }
        );

        // Chỉ gửi token về client
        res.status(200).json({
            data: {
                token: token,
            },
            message: 'Đăng nhập thành công',
            success: true,
        });
    } catch (error) {
        console.error('Lỗi đăng nhập:', error);
        res.status(500).json({ 
            message: 'Lỗi server', 
            success: false 
        });
    }
};

exports.register = async (req, res) => {
    const { email, password, firstName, lastName } = req.body;
    const UserModel = require('../models/UserModel');
    console.log('Đăng ký người dùng:', req.body); // Thêm dòng này để kiểm tra dữ liệu đầu vào
    try {
        // Kiểm tra xem email đã tồn tại chưa
        const existingUser = await UserModel.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'Email đã được sử dụng' , success: false });
        }

        // Mã hóa mật khẩu
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Tạo người dùng mới
        const newUser = new UserModel({
            email,
            password: hashedPassword,
            firstName,
            lastName,
        });

        // Lưu người dùng vào database
        await newUser.save();

       
        // Gửi phản hồi thành công
        res.status(200).json({
            message: 'Đăng ký thành công',
            success: true,
        
        });
    } catch (error) {
        console.error('Lỗi đăng ký:', error);
        res.status(500).json({ message: 'Lỗi server', success: false });
    }
};
exports.getUserProfile = async (req, res) => {
    try {
      const UserModel = require('../models/UserModel');
      
      // Lấy userId từ token đã giải mã
      const userId = req.user.userId;
      
      // Tìm thông tin người dùng trong database
      const user = await UserModel.findById(userId); 
      
      if (!user) {
        return res.status(404).json({ 
          message: 'Không tìm thấy thông tin người dùng', 
          success: false 
        });
      }
      // Trả về thông tin người dùng
      return res.status(200).json({
        data: user,
        message: 'Lấy thông tin người dùng thành công',
        success: true
      });
    } catch (error) {
      console.error('Lỗi lấy thông tin người dùng:', error);
      res.status(500).json({ 
        message: 'Lỗi server', 
        success: false 
      });
    }
  };


// Thêm hàm cập nhật thông tin người dùng
exports.updateUserProfile = async (req, res) => {
    console.log('Cập nhật thông tin người dùng:', req.body); // Thêm dòng này để kiểm tra dữ liệu đầu vào
    const UserModel = require('../models/UserModel');
    try {
        // Lấy ID người dùng từ token
        const userId = req.user.userId;
        
        // Lấy các trường cần cập nhật từ request body
        const { firstName, lastName, password, language_selected, profile_image_url } = req.body;
        
        // Tìm user hiện tại
        const user = await UserModel.findById(userId);
        
        if (!user) {
            return res.status(404).json({
                message: 'Không tìm thấy người dùng',
                success: false
            });
        }
        
       
        
        // Chỉ thêm vào user các trường được gửi lên
        if (firstName !== undefined && firstName!="") user.firstName = firstName;
        if (lastName !== undefined&& lastName !="") user.lastName = lastName;
        if (language_selected !== undefined&& language_selected !="") user.language_selected = language_selected;
        if (profile_image_url !== undefined && profile_image_url !=="") user.profile_image_url = profile_image_url;
        
        // Xử lý riêng với password nếu có
        if (password) {
            const salt = await bcrypt.genSalt(10);
            user.password = await bcrypt.hash(password, salt);
        }
        await user.save();
        return res.status(200).json({
            message: 'Cập nhật thông tin thành công',
            success: true
        });
        
    } catch (error) {
        console.error('Lỗi cập nhật thông tin:', error);
        res.status(500).json({
            message: 'Lỗi server',
            success: false
        });
    }
};