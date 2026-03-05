import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getScores(context),
    HttpMethod.post => _saveScore(context),
    _ => Future.value(
      Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: 'Method Not Allowed',
      ),
    ),
  };
}

Future<Response> _getScores(RequestContext context) async {
  final pool = context.read<Pool<Object>>();
  final result = await pool.execute(
    'SELECT id, name, score, created_at FROM high_scores '
    'ORDER BY score DESC LIMIT 25',
  );
  final scores =
      result
          .map(
            (row) => {
              'id': row[0],
              'name': row[1],
              'score': row[2],
              'created_at': (row[3] as DateTime?)?.toIso8601String(),
            },
          )
          .toList();
  return Response.json(body: scores);
}

Future<Response> _saveScore(RequestContext context) async {
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } catch (_) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Invalid JSON body'},
    );
  }

  final name = (body['name'] as String? ?? '').trim();
  if (name.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'name must not be empty'},
    );
  }

  final pool = context.read<Pool<Object>>();
  final result = await pool.execute(
    Sql.named(
      'INSERT INTO high_scores (name, score) VALUES (@name, @score) '
      'RETURNING id, name, score, created_at',
    ),
    parameters: {'name': name, 'score': body['score'] as int? ?? 0},
  );
  final row = result.first;
  return Response.json(
    statusCode: HttpStatus.created,
    body: {
      'id': row[0],
      'name': row[1],
      'score': row[2],
      'created_at': (row[3] as DateTime?)?.toIso8601String(),
    },
  );
}
