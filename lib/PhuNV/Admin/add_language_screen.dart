import 'package:flutter/material.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:language_app/models/language_model.dart';
import 'package:language_app/widget/top_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddLanguageScreen extends StatefulWidget {
  final LanguageModel? language;
  final bool isEditing;

  const AddLanguageScreen({
    Key? key,
    this.language,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AddLanguageScreen> createState() => _AddLanguageScreenState();
}

class _AddLanguageScreenState extends State<AddLanguageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _imageFile;
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Nếu đang chỉnh sửa ngôn ngữ, điền thông tin sẵn có
    if (widget.isEditing && widget.language != null) {
      _nameController.text = widget.language!.name;
      _codeController.text = widget.language!.code;
      _descriptionController.text = widget.language!.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}');
        print('Image name: ${pickedFile.name}');

        final file = File(pickedFile.path);
        final fileExtension = pickedFile.path.split('.').last.toLowerCase();

        // Kiểm tra extension
        if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
          setState(() {
            _imageFile = file;
          });

          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã chọn ảnh thành công')),
          );
        } else {
          // Hiển thị thông báo lỗi nếu không phải là ảnh hợp lệ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Vui lòng chọn file ảnh có định dạng jpg, jpeg, png hoặc gif'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Lỗi khi chọn ảnh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveLanguage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Kiểm tra ảnh
    if (!widget.isEditing && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ảnh cho ngôn ngữ')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    bool success = false;

    if (widget.isEditing && widget.language != null) {
      // Cập nhật ngôn ngữ
      success = await languageProvider.updateLanguage(
        id: widget.language!.id,
        name: _nameController.text,
        description: _descriptionController.text,
        imageFile: _imageFile,
      );
    } else {
      // Thêm ngôn ngữ mới
      success = await languageProvider.createLanguage(
        name: _nameController.text,
        code: _codeController.text,
        description: _descriptionController.text,
        imageFile: _imageFile!,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing
              ? 'Đã cập nhật ngôn ngữ thành công'
              : 'Đã thêm ngôn ngữ mới thành công'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi:"Không thể lưu ngôn ngữ"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.indigo.shade50],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopBar(
                title: widget.isEditing
                    ? "Chỉnh sửa ngôn ngữ"
                    : "Thêm ngôn ngữ mới",
              ),
            ),
            Positioned(
              top: 100 * pix,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh ngôn ngữ
                      Center(
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _imageFile!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : widget.isEditing && widget.language != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          widget.language!.imageUrl,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.add_photo_alternate,
                                              size: 50,
                                              color: Colors.grey[500],
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.add_photo_alternate,
                                        size: 50,
                                        color: Colors.grey[500],
                                      ),
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: _pickImage,
                          child: Text(
                            'Nhấn để chọn ảnh',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Form nhập thông tin
                      Text(
                        'Tên ngôn ngữ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên ngôn ngữ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên ngôn ngữ';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Mã ngôn ngữ
                      Text(
                        'Mã ngôn ngữ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          hintText: 'Nhập mã ngôn ngữ (vd: en, vi, fr)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        enabled: !widget
                            .isEditing, // Không cho phép sửa mã khi đang chỉnh sửa
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mã ngôn ngữ';
                          }
                          if (!RegExp(r'^[a-z]{2,5}$').hasMatch(value)) {
                            return 'Mã ngôn ngữ phải từ 2-5 ký tự chữ thường';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Mô tả ngôn ngữ
                      Text(
                        'Mô tả',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Nhập mô tả ngôn ngữ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mô tả ngôn ngữ';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),

                      // Nút lưu
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveLanguage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  widget.isEditing
                                      ? 'Cập nhật'
                                      : 'Thêm ngôn ngữ',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
