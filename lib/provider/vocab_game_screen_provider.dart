import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Topic {
  final String name;
  final String description;
  final String id;

  Topic({required this.name, required this.description, required this.id});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class VocabularyGameScreenProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<Topic> _topics = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Topic> get topics => _topics;

  VocabularyGameScreenProvider() {
    fetchTopics();
  }

  // Get the appropriate icon for each topic
  IconData getIconForTopic(String topicName) {
    switch (topicName) {
      case 'Động vật':
        return Icons.pets;
      case 'Thực phẩm':
        return Icons.fastfood;
      case 'Giao thông':
        return Icons.directions_car;
      default:
        return Icons.book;
    }
  }

  // Fetch topics from API or use mock data
  Future<void> fetchTopics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // This would be replaced with actual API call
      await Future.delayed(Duration(milliseconds: 500));

      // Mock data for now
      _topics = [
        Topic(id: '1', name: 'Động vật', description: 'Từ vựng về động vật'),
        Topic(id: '2', name: 'Thực phẩm', description: 'Từ vựng về đồ ăn'),
        Topic(
            id: '3', name: 'Giao thông', description: 'Từ vựng về phương tiện'),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Không thể tải chủ đề: $e";
      notifyListeners();
    }
  }
}
