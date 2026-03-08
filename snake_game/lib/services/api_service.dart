import 'package:shared_models/shared_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final _client = Supabase.instance.client;

  Future<List<Score>> fetchTopScores() async {
    final data = await _client
        .from('high_scores')
        .select('name, score')
        .order('score', ascending: false)
        .limit(25);
    return (data as List)
        .map((e) => Score.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitScore(Score score) async {
    await _client.from('high_scores').insert(score.toJson());
  }
}
