import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordPair {
  final String word;
  final String translation;

  WordPair({required this.word, required this.translation});

  factory WordPair.fromJson(Map<String, dynamic> json) {
    return WordPair(
      word: json['word'] ?? '',
      translation: json['translation'] ?? '',
    );
  }
}

class VocabularyWord {
  final int id;
  final String word;
  final String definition;
  final int vocabTopicId;
  final String transcription;
  final String example;
  final String exampleTranslation;
  final String imageUrl;
  final String createdAt;
  final String updatedAt;

  VocabularyWord({
    required this.id,
    required this.word,
    required this.definition,
    required this.vocabTopicId,
    required this.transcription,
    required this.example,
    required this.exampleTranslation,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] ?? 0,
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      vocabTopicId: json['vocabTopicId'] ?? 0,
      transcription: json['transcription'] ?? '',
      example: json['example'] ?? '',
      exampleTranslation: json['exampleTranslation'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class ScrambleWordItem {
  final int id;
  final String word;
  final String definition;
  final String example;
  final String exampleTranslation;
  final String imageUrl;
  final String scrambled;

  ScrambleWordItem({
    required this.id,
    required this.word,
    required this.definition,
    required this.example,
    required this.exampleTranslation,
    required this.imageUrl,
    required this.scrambled,
  });

  factory ScrambleWordItem.fromJson(Map<String, dynamic> json) {
    final wordData = json['word'] as Map<String, dynamic>;
    return ScrambleWordItem(
      id: wordData['id'] ?? 0,
      word: wordData['word'] ?? '',
      definition: wordData['definition'] ?? '',
      example: wordData['example'] ?? '',
      exampleTranslation: wordData['exampleTranslation'] ?? '',
      imageUrl: wordData['imageUrl'] ?? '',
      scrambled: json['scrambled'] ?? '',
    );
  }
}

enum GameType {
  wordLink,
  scramble,
  listening,
}

class VocabularyGameProvider with ChangeNotifier {
  final String baseUrl = UrlUtils.getBaseUrl();
  bool _isLoading = false;
  String? _errorMessage;
  GameType _currentGameType = GameType.wordLink;
  List<WordPair> _wordPairs = [];
  List<ScrambleWordItem> _scrambleWords = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  GameType get currentGameType => _currentGameType;
  List<WordPair> get wordPairs => _wordPairs;
  List<ScrambleWordItem> get scrambleWords => _scrambleWords;

  // Fetch word-link game data
  Future<void> fetchWordLinkGame(String topicId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentGameType = GameType.wordLink;
    _wordPairs = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final uri =
          Uri.parse("${baseUrl}vocab-topics/$topicId/vocab-games/word-link");

      print("Fetching word-link game data from: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null && data['data']['data'] is List) {
          final wordPairsJson = data['data']['data'] as List;
          _wordPairs = wordPairsJson
              .map((pairJson) => WordPair.fromJson(pairJson))
              .toList();

          print("Loaded ${_wordPairs.length} word pairs for word-link game");
        } else {
          print("Invalid response format: ${response.body}");
          _errorMessage = "Dữ liệu trò chơi không hợp lệ";
        }
      } else {
        _errorMessage =
            "Không thể tải dữ liệu trò chơi: ${response.statusCode}";
        print(
            "Failed to load word-link game: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải dữ liệu trò chơi: $e";
      print("Error fetching word-link game: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch scramble game data
  Future<void> fetchScrambleGame(String topicId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentGameType = GameType.scramble;
    _scrambleWords = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final uri =
          Uri.parse("${baseUrl}vocab-topics/$topicId/vocab-games/scramble");

      print("Fetching scramble game data from: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null && data['data']['data'] is List) {
          final scrambleWordsJson = data['data']['data'] as List;
          _scrambleWords = scrambleWordsJson
              .map((wordJson) => ScrambleWordItem.fromJson(wordJson))
              .toList();

          print("Loaded ${_scrambleWords.length} words for scramble game");
        } else {
          print("Invalid response format: ${response.body}");
          _errorMessage = "Dữ liệu trò chơi không hợp lệ";
        }
      } else {
        _errorMessage =
            "Không thể tải dữ liệu trò chơi: ${response.statusCode}";
        print(
            "Failed to load scramble game: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải dữ liệu trò chơi: $e";
      print("Error fetching scramble game: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchListeningGame(String topicId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentGameType = GameType.listening;
    _listeningWords = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    try {
      final uri =
          Uri.parse("${baseUrl}vocab-topics/$topicId/vocab-games/listening");

      print("Fetching listening game data from: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null && data['data']['data'] is List) {
          final wordsData = data['data']['data'] as List;
          _listeningWords =
              wordsData.map((item) => VocabularyWord.fromJson(item)).toList();

          print("Loaded ${_listeningWords.length} words for listening game");

          if (_listeningWords.isEmpty) {
            _errorMessage = "Không có từ vựng cho bài tập nghe.";
          }
        } else {
          print("Invalid response format: ${response.body}");
          _errorMessage = "Dữ liệu trò chơi không hợp lệ";
        }
      } else {
        _errorMessage =
            "Không thể tải dữ liệu trò chơi: ${response.statusCode}";
        print(
            "Failed to load listening game: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải dữ liệu trò chơi: $e";
      print("Error fetching listening game: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // List to store vocabulary words for the listening game
  List<VocabularyWord> _listeningWords = [];
  List<VocabularyWord> get listeningWords => _listeningWords;
}
