import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_models/shared_models.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'http://localhost:8080';

  final http.Client _client;

  Future<List<Score>> fetchTopScores() async {
    final response = await _client.get(Uri.parse('$_baseUrl/scores'));
    final data = jsonDecode(response.body) as List;
    return data.map((e) => Score.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> submitScore(Score score) async {
    await _client.post(
      Uri.parse('$_baseUrl/scores'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(score.toJson()),
    );
  }
}
