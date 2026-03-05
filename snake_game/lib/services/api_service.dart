import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_models/shared_models.dart';

class ApiService {
  static const _base = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  Future<List<Score>> fetchTopScores() async {
    final res = await http.get(Uri.parse('$_base/scores'));
    if (res.statusCode != 200) {
      throw Exception('fetchTopScores failed: ${res.statusCode}');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Score.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> submitScore(Score score) async {
    final res = await http.post(
      Uri.parse('$_base/scores'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(score.toJson()),
    );
    if (res.statusCode != 201) {
      throw Exception('submitScore failed: ${res.statusCode}');
    }
  }
}
