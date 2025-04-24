const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    email : {
        type: String,
        required: true,
        unique: true,
    },
    password: {
        type: String,
        required: true,
    },
    firstName: {
        type: String,
        required: true,
    },
    lastName: {
        type: String,
        required: true,
    },
    role: {
        type: String,
        enum: ['admin', 'user'],
        default: 'user',
    },
    profile_image_url: {
        type: String,
        default: 'https://icons.iconarchive.com/icons/papirus-team/papirus-status/512/avatar-default-icon.png', // Đường dẫn đến ảnh mặc định
    },
    language_selected: {
        type: String,
        default: '',
    },
    
    
}
, {
    timestamps: true,
});
module.exports = mongoose.model('User', userSchema);