import 'package:dart_frog/dart_frog.dart';
import 'package:shared_models/shared_models.dart';

// In-memory store — lives for the lifetime of the server process.
final List<Score> _scores = [];

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _handleGet(),
    HttpMethod.post => _handlePost(context),
    _ => Response(statusCode: 405, body: 'Method Not Allowed'),
  };
}

Response _handleGet() {
  final sorted = [..._scores]..sort((a, b) => b.score.compareTo(a.score));
  final top25 = sorted.take(25).map((s) => s.toJson()).toList();
  return Response.json(body: top25);
}

Future<Response> _handlePost(RequestContext context) async {
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } catch (_) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid JSON body'},
    );
  }

  final name = (body['name'] as String? ?? '').trim();
  if (name.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'name must not be empty'},
    );
  }

  final score = Score(name: name, score: body['score'] as int? ?? 0);
  _scores.add(score);
  return Response.json(statusCode: 201, body: score.toJson());
}
