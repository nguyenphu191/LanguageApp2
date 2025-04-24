const jwt = require('jsonwebtoken');
const Language = require('../models/LanguageModel');
const fs = require('fs');
const path = require('path');
// Lấy tất cả ngôn ngữ
exports.getAllLanguages = async (req, res) => {
  try {
    const languages = await Language.find();
    
    // Thêm hostname vào đường dẫn ảnh
    const baseUrl = `${req.protocol}://${req.get('host')}/`;
    const languagesWithFullImageUrl = languages.map(language => {
      const languageObj = language.toObject();
      languageObj.imageUrl = baseUrl + languageObj.imageUrl;
      return languageObj;
    });
    
    res.status(200).json({
      success: true,
      count: languages.length,
      data: languagesWithFullImageUrl
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách ngôn ngữ',
      error: error.message
    });
  }
};

// Lấy một ngôn ngữ theo ID
exports.getLanguageById = async (req, res) => {
  try {
    const language = await Language.findById(req.params.id);
    
    if (!language) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy ngôn ngữ với ID này'
      });
    }
    
    // Thêm hostname vào đường dẫn ảnh
    const languageObj = language.toObject();
    languageObj.imageUrl = `${req.protocol}://${req.get('host')}/${languageObj.imageUrl}`;
    
    res.status(200).json({
      success: true,
      data: languageObj
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin ngôn ngữ',
      error: error.message
    });
  }
};
// Lấy một ngôn ngữ theo mã code
exports.getLanguageByCode = async (req, res) => {
  try {
    const language = await Language.findOne({ code: req.params.code });
    
    if (!language) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy ngôn ngữ với mã này'
      });
    }
    
    // Thêm hostname vào đường dẫn ảnh
    const languageObj = language.toObject();
    languageObj.imageUrl = `${req.protocol}://${req.get('host')}/${languageObj.imageUrl}`;
    
    res.status(200).json({
      success: true,
      data: languageObj
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin ngôn ngữ',
      error: error.message
    });
  }
};

exports.createLanguage = async (req, res) => {
  try {
    console.log('Create language request received');
    console.log('Body:', req.body);
    console.log('File:', req.file);
    
    const { name, code, description } = req.body;
    
    // Kiểm tra dữ liệu đầu vào
    if (!name || !code || !description) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng cung cấp đầy đủ thông tin: name, code, description'
      });
    }
    
    // Xác định đường dẫn ảnh
    let imageUrl = '';
    if (req.file) {
      // Sử dụng đường dẫn từ req.file.path, nhưng chuyển dấu \ thành /
      imageUrl = req.file.path.replace(/\\/g, '/');
      console.log('Image URL created:', imageUrl);
    } else {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng cung cấp ảnh cho ngôn ngữ'
      });
    }
    
    const newLanguage = new Language({
      name,
      code,
      imageUrl,
      description
    });
    
    const savedLanguage = await newLanguage.save();
    
    // Trả về URL đầy đủ trong response
    const fullLanguage = savedLanguage.toObject();
    fullLanguage.imageUrl = `${req.protocol}://${req.get('host')}/${imageUrl}`;
    
    res.status(201).json({
      success: true,
      data: fullLanguage
    });
  } catch (error) {
    console.error('Error creating language:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo ngôn ngữ mới',
      error: error.message
    });
  }
};

// Cập nhật ngôn ngữ
exports.updateLanguage = async (req, res) => {
  try {
    const { name, description } = req.body;
    
    // Tìm ngôn ngữ cần cập nhật
    const language = await Language.findById(req.params.id);
    if (!language) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy ngôn ngữ với ID này'
      });
    }
    
    // Cập nhật thông tin
    if (name) language.name = name;
    if (description) language.description = description;
    
    // Nếu có upload ảnh mới
    if (req.file) {
      // Chỉ lưu đường dẫn tương đối
      language.imageUrl = `uploads/languages/${req.file.filename}`;
    }
    
    const updatedLanguage = await language.save();
    
    // Khi trả về cho client, thêm baseURL vào imageUrl
    const languageResponse = updatedLanguage.toObject();
    languageResponse.imageUrl = `${req.protocol}://${req.get('host')}/${updatedLanguage.imageUrl}`;
    
    res.status(200).json({
      success: true,
      data: languageResponse
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật ngôn ngữ',
      error: error.message
    });
  }
};

// Xóa ngôn ngữ
exports.deleteLanguage = async (req, res) => {
  try {
    const language = await Language.findById(req.params.id);
    
    if (!language) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy ngôn ngữ với ID này'
      });
    }
    
    // Xóa file ảnh nếu tồn tại
    if (language.imageUrl) {
      try {
        // Lấy đường dẫn đầy đủ của file
        const imagePath = path.join(__dirname, '..', language.imageUrl);
        
        // Kiểm tra nếu file tồn tại
        if (fs.existsSync(imagePath)) {
          // Xóa file
          fs.unlinkSync(imagePath);
          console.log(`Đã xóa file ảnh: ${imagePath}`);
        } else {
          console.log(`File ảnh không tồn tại: ${imagePath}`);
        }
      } catch (err) {
        console.error('Lỗi khi xóa file ảnh:', err);
        // Tiếp tục xóa ngôn ngữ ngay cả khi không thể xóa ảnh
      }
    }
    
    // Xóa ngôn ngữ khỏi cơ sở dữ liệu
    await Language.findByIdAndDelete(req.params.id);
    
    res.status(200).json({
      success: true,
      message: 'Ngôn ngữ đã được xóa thành công'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa ngôn ngữ',
      error: error.message
    });
  }
};