const Vocabulary = require('../models/VocabularyModel');
const Topic = require('../models/TopicModel');

// Lấy tất cả từ vựng
exports.getAllVocabularies = async (req, res) => {
  try {
    const { topicId, difficulty } = req.query;
    let query = {};
    
    // Lọc theo chủ đề nếu được cung cấp
    if (topicId) {
      query.topicId = topicId;
    }
    
    // Lọc theo độ khó nếu được cung cấp
    if (difficulty) {
      query.difficulty = difficulty;
    }
    
    // Lấy danh sách từ vựng và populate thông tin chủ đề
    const vocabularies = await Vocabulary.find(query)
      .populate('topicId', 'topic languageId');
    
    // Tạo URL cơ sở
    const baseUrl = `${req.protocol}://${req.get('host')}/`;
    
    // Chuyển đổi định dạng để phù hợp với VocabularyModel của Flutter
    const formattedVocabularies = vocabularies.map(vocab => {
      const vocabObj = vocab.toJSON();
      
      // Thêm hostname vào đường dẫn ảnh nếu cần
      if (vocabObj.imageUrl && !vocabObj.imageUrl.startsWith('http')) {
        vocabObj.imageUrl = baseUrl + vocabObj.imageUrl;
      }
      
      // Thêm thông tin topic
      vocabObj.topic = vocabObj.topicId.topic;
      vocabObj.languageId = vocabObj.topicId.languageId;
      vocabObj.topicid = vocabObj.topicId._id;
      
      return vocabObj;
    });
    
    res.status(200).json({
      success: true,
      count: formattedVocabularies.length,
      data: formattedVocabularies
    });
  } catch (error) {
    console.error('Error in getAllVocabularies:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách từ vựng',
      error: error.message
    });
  }
};

// Lấy một từ vựng theo ID
exports.getVocabularyById = async (req, res) => {
  try {
    const vocabulary = await Vocabulary.findById(req.params.id)
      .populate('topicId', 'topic languageId');
    
    if (!vocabulary) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy từ vựng với ID này'
      });
    }
    
    // Tạo URL cơ sở
    const baseUrl = `${req.protocol}://${req.get('host')}/`;
    
    // Chuyển đổi định dạng để phù hợp với VocabularyModel của Flutter
    const vocabObj = vocabulary.toJSON();
    
    // Thêm hostname vào đường dẫn ảnh nếu cần
    if (vocabObj.imageUrl && !vocabObj.imageUrl.startsWith('http')) {
      vocabObj.imageUrl = baseUrl + vocabObj.imageUrl;
    }
    
    // Thêm thông tin topic
    vocabObj.topic = vocabObj.topicId.topic;
    vocabObj.languageId = vocabObj.topicId.languageId;
    vocabObj.topicid = vocabObj.topicId._id;
    
    res.status(200).json({
      success: true,
      data: vocabObj
    });
  } catch (error) {
    console.error('Error in getVocabularyById:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin từ vựng',
      error: error.message
    });
  }
};

// Lấy từ vựng theo chủ đề
exports.getVocabulariesByTopic = async (req, res) => {
  try {
    const { topicId } = req.params;
    
    // Kiểm tra chủ đề tồn tại
    const topic = await Topic.findById(topicId);
    if (!topic) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy chủ đề với ID này'
      });
    }
    
    // Lấy danh sách từ vựng thuộc chủ đề
    const vocabularies = await Vocabulary.find({ topicId });
    if(vocabularies.length === 0) {
      return res.status(201).json({
        success: true,
        message: 'Không có từ vựng nào trong chủ đề này',
        data: []
      });
    }else{
    
    return res.status(200).json({
      success: true,
      count: vocabularies.length,
      data: vocabularies
    });}
  } catch (error) {
    console.error('Error in getVocabulariesByTopic:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách từ vựng theo chủ đề',
      error: error.message
    });
  }
};

// Tạo từ vựng mới
exports.createVocabulary = async (req, res) => {
  try {
    const { 
      word, 
      definition, 
      example, 
      exampleTranslation, 
      difficulty, 
      topicId, 
      imageUrl 
    } = req.body;
    
    // Kiểm tra dữ liệu đầu vào
    if (!word || !definition || !example || !exampleTranslation || !topicId) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng cung cấp đầy đủ thông tin từ vựng'
      });
    }
    
    // Kiểm tra chủ đề tồn tại
    const topic = await Topic.findById(topicId);
    if (!topic) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy chủ đề với ID này'
      });
    }
    
    // Tạo từ vựng mới
    const newVocabulary = new Vocabulary({
      word,
      definition,
      example,
      exampleTranslation,
      difficulty: difficulty || 'medium',
      topicId,
      imageUrl: imageUrl || ''
    });
    
    // Lưu từ vựng
    const savedVocabulary = await newVocabulary.save();
    // Tăng số lượng từ vựng trong chủ đề
    topic.numbervocabulary = (topic.numbervocabulary || 0) + 1;
    await topic.save();
    



    
   
    console.log('Vocabulary created:', savedVocabulary);
    res.status(200).json({
      success: true,
      data: savedVocabulary
    });
  } catch (error) {
    console.error('Error in createVocabulary:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo từ vựng mới',
      error: error.message
    });
  }
};

// Cập nhật từ vựng
exports.updateVocabulary = async (req, res) => {
  try {
    const { 
      word, 
      definition, 
      example, 
      exampleTranslation, 
      difficulty, 
      topicId, 
      imageUrl 
    } = req.body;
    
    // Tìm từ vựng cần cập nhật
    const vocabulary = await Vocabulary.findById(req.params.id);
    
    if (!vocabulary) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy từ vựng với ID này'
      });
    }
    
    // Cập nhật thông tin
    if (word) vocabulary.word = word;
    if (definition) vocabulary.definition = definition;
    if (example) vocabulary.example = example;
    if (exampleTranslation) vocabulary.exampleTranslation = exampleTranslation;
    if (difficulty) vocabulary.difficulty = difficulty;
    if (imageUrl !== undefined) vocabulary.imageUrl = imageUrl;
    
    // Kiểm tra nếu thay đổi chủ đề
    let oldTopicId = vocabulary.topicId;
    if (topicId && topicId !== vocabulary.topicId.toString()) {
      // Kiểm tra chủ đề mới tồn tại
      const newTopic = await Topic.findById(topicId);
      if (!newTopic) {
        return res.status(404).json({
          success: false,
          message: 'Không tìm thấy chủ đề mới với ID này'
        });
      }
      
      vocabulary.topicId = topicId;
      
      // Cập nhật số lượng từ vựng ở chủ đề cũ và mới
      const oldTopic = await Topic.findById(oldTopicId);
      if (oldTopic) {
        oldTopic.numbervocabulary = Math.max(0, (oldTopic.numbervocabulary || 0) - 1);
        await oldTopic.save();
      }
      
      newTopic.numbervocabulary = (newTopic.numbervocabulary || 0) + 1;
      await newTopic.save();
    }
    
    // Lưu từ vựng đã cập nhật
    const updatedVocabulary = await vocabulary.save();
    
    // Populate thông tin chủ đề
    await updatedVocabulary.populate('topicId', 'topic languageId');
    
    // Tạo URL cơ sở
    const baseUrl = `${req.protocol}://${req.get('host')}/`;
    
    // Chuyển đổi định dạng để phù hợp với VocabularyModel của Flutter
    const vocabObj = updatedVocabulary.toJSON();
    
    // Thêm hostname vào đường dẫn ảnh nếu cần
    if (vocabObj.imageUrl && !vocabObj.imageUrl.startsWith('http')) {
      vocabObj.imageUrl = baseUrl + vocabObj.imageUrl;
    }
    
    // Thêm thông tin topic
    vocabObj.topic = vocabObj.topicId.topic;
    vocabObj.languageId = vocabObj.topicId.languageId;
    vocabObj.topicid = vocabObj.topicId._id;
    
    res.status(200).json({
      success: true,
      data: vocabObj
    });
  } catch (error) {
    console.error('Error in updateVocabulary:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật từ vựng',
      error: error.message
    });
  }
};

// Xóa từ vựng
exports.deleteVocabulary = async (req, res) => {
  try {
    // Tìm từ vựng cần xóa
    const vocabulary = await Vocabulary.findById(req.params.id);
    
    if (!vocabulary) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy từ vựng với ID này'
      });
    }
    
    // Lưu topicId trước khi xóa từ vựng
    const topicId = vocabulary.topicId;
    
    // Xóa từ vựng
    await Vocabulary.findByIdAndDelete(req.params.id);
    
    // Giảm số lượng từ vựng trong chủ đề
    const topic = await Topic.findById(topicId);
    if (topic) {
      topic.numbervocabulary = Math.max(0, (topic.numbervocabulary || 0) - 1);
      await topic.save();
    }
    
    res.status(200).json({
      success: true,
      message: 'Từ vựng đã được xóa thành công'
    });
  } catch (error) {
    console.error('Error in deleteVocabulary:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa từ vựng',
      error: error.message
    });
  }
};