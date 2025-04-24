const Topic = require('../models/TopicModel');
const Language = require('../models/LanguageModel');
const fs = require('fs');
const path = require('path');
// Lấy tất cả chủ đề
exports.getAllTopics = async (req, res) => {
  try {
    const { languageId, level } = req.query;
    let query = {};
    
  
    
    // Lọc theo ngôn ngữ nếu được cung cấp
    if (languageId) {
      query.languageId = languageId;
      console.log('Using languageId in query:', languageId);
    }
    
    // Lọc theo cấp độ nếu được cung cấp
    if (level) {
      query.level = level;
    }
    
    
    // Thêm log truy vấn thực tế
    const topics = await Topic.find(query);
    
    // Thêm log chi tiết nếu không tìm thấy kết quả
    // if (topics.length === 0) {
    //   // Tìm tất cả topics để xem có bao nhiêu và languageId của chúng
    //   const allTopics = await Topic.find();
    //   console.log('All topics:', allTopics.map(t => ({
    //     id: t._id,
    //     topic: t.topic,
    //     languageId: t.languageId
    //   })));
    // }
    
    // Tạo URL cơ sở
    const baseUrl = `${req.protocol}://${req.get('host')}/`;
    
    // Thêm hostname vào đường dẫn ảnh trước khi trả về
    const topicsWithFullImageUrl = topics.map(topic => {
      const topicObj = topic.toObject();
      
      // Thêm hostname nếu imageUrl không bắt đầu bằng http:// hoặc https://
      if (topicObj.imageUrl && !topicObj.imageUrl.startsWith('http')) {
        topicObj.imageUrl = baseUrl + topicObj.imageUrl;
      }
      
      return topicObj;
    });
    
    res.status(200).json({
      success: true,
      count: topics.length,
      data: topicsWithFullImageUrl
    });
  } catch (error) {
    console.error('Error in getAllTopics:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách chủ đề',
      error: error.message
    });
  }
};

// Lấy một chủ đề theo ID
exports.getTopicById = async (req, res) => {
  try {
    const topic = await Topic.findById(req.params.id);
    
    if (!topic) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy chủ đề với ID này'
      });
    }
    
    // Thêm hostname vào đường dẫn ảnh
    const topicObj = topic.toObject();
    const baseUrl = `${req.protocol}://${req.get('host')}/`;
    if (topicObj.imageUrl && !topicObj.imageUrl.startsWith('http')) {
      topicObj.imageUrl = baseUrl + topicObj.imageUrl;
    }
    
    res.status(200).json({
      success: true,
      data: {
        ...topicObj,
        id: topicObj._id,
        image: topicObj.imageUrl,
        createAt: topicObj.createdAt,
        updateAt: topicObj.updatedAt
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin chủ đề',
      error: error.message
    });
  }
};

// Tạo chủ đề mới
exports.createTopic = async (req, res) => {
  try {
    // console.log('Create topic request received');
    // console.log('Body:', req.body);
    // console.log('File:', req.file);
    
    const { topic, languageId, level } = req.body;
    
    // Kiểm tra dữ liệu đầu vào
    if (!topic || !languageId || !level) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng cung cấp đầy đủ thông tin: topic, languageId, level'
      });
    }
    
    // Xác định đường dẫn ảnh
    let imageUrl = '';
    if (req.file) {
      // Sử dụng đường dẫn từ req.file.path, nhưng chuyển dấu \ thành /
      imageUrl = req.file.path.replace(/\\/g, '/');
    } else {
      console.log('No file was found in the request');
      return res.status(400).json({
        success: false,
        message: 'Vui lòng cung cấp ảnh cho chủ đề'
      });
    }
    
    const newTopic = new Topic({
      topic,
      imageUrl,
      languageId,
      level,
      numbervocabulary: 0
    });
    
    const savedTopic = await newTopic.save();
    
    // Trả về URL đầy đủ trong response
    const fullTopic = savedTopic.toObject();
    fullTopic.imageUrl = `${req.protocol}://${req.get('host')}/${imageUrl}`;
    
    res.status(201).json({
      success: true,
      data: fullTopic
    });
  } catch (error) {
    console.error('Error creating topic:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo chủ đề mới',
      error: error.message
    });
  }
};

// Cập nhật chủ đề
exports.updateTopic = async (req, res) => {
  try {
    const { topic, languageId, level } = req.body;
    
    // Tìm chủ đề cần cập nhật
    const existingTopic = await Topic.findById(req.params.id);
    if (!existingTopic) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy chủ đề với ID này'
      });
    }
    
    // Cập nhật thông tin
    if (topic) existingTopic.topic = topic;
    if (level) existingTopic.level = level;
    if (languageId) existingTopic.languageId = languageId;
    
    // Nếu có upload ảnh mới
    if (req.file) {
      existingTopic.imageUrl = `uploads/topics/${req.file.filename}`;
    }
    
    const updatedTopic = await existingTopic.save();
    const topicObj = updatedTopic.toObject();
    
    // Thêm hostname vào đường dẫn ảnh
    const baseUrl = `${req.protocol}://${req.get('host')}/`;
    
    res.status(200).json({
      success: true,
      data: {
        ...topicObj,
        id: topicObj._id,
        imageUrl: baseUrl + topicObj.imageUrl,
        image: baseUrl + topicObj.imageUrl,
        createAt: topicObj.createdAt,
        updateAt: topicObj.updatedAt
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật chủ đề',
      error: error.message
    });
  }
};
// Xóa chủ đề
exports.deleteTopic = async (req, res) => {
  try {
    const topic = await Topic.findById(req.params.id);
    
    if (!topic) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy chủ đề với ID này'
      });
    }
    
    // Xóa file ảnh nếu tồn tại
    if (topic.imageUrl) {
      try {
        // Lấy đường dẫn đầy đủ của file
        const imagePath = path.join(__dirname, '..', topic.imageUrl);
        
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
        // Tiếp tục xóa chủ đề ngay cả khi không thể xóa ảnh
      }
    }
    
    // Xóa chủ đề khỏi cơ sở dữ liệu
    await Topic.findByIdAndDelete(req.params.id);
    
    res.status(200).json({
      success: true,
      message: 'Chủ đề đã được xóa thành công'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa chủ đề',
      error: error.message
    });
  }
};

