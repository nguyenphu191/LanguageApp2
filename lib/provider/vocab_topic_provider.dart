import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:language_app/utils/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardEntry {
  final String name;
  final int time;

  LeaderboardEntry({required this.name, required this.time});

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'] ?? '',
      time: json['time'] ?? 0,
    );
  }
}

class VocabularyTopicProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<LeaderboardEntry> _leaderboard = [];
  int? _personalBestTime;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  int? get personalBestTime => _personalBestTime;
  bool get hasPersonalBest => _personalBestTime != null;

  // Mock data for now - in a real app, you'd fetch this from an API
  Future<void> fetchLeaderboard(String topicId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // This would be replaced with actual API call
      await Future.delayed(Duration(milliseconds: 500));

      // Mock data
      _leaderboard = [
        LeaderboardEntry(name: 'Nguyen Van A', time: 120),
        LeaderboardEntry(name: 'Tran Thi B', time: 150),
        LeaderboardEntry(name: 'Le Van C', time: 180),
      ];

      // Mock personal best (null means not completed yet)
      _personalBestTime = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Không thể tải bảng xếp hạng: $e";
      notifyListeners();
    }
  }

  // Function to start the game
  void startGame(String topicId, String topicName) {
    // Logic to start the game if needed
    notifyListeners();
  }
}
