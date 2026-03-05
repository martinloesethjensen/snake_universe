import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:snake_backend/database.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getScores(context),
    HttpMethod.post => _saveScore(context),
    _ => Response(
      statusCode: HttpStatus.methodNotAllowed,
      body: 'Method Not Allowed',
    ),
  };
}

Future<Response> _getScores(RequestContext context) async {
  final db = context.read<AppDatabase>();
  final query = db.select(db.highScores)
    ..orderBy([
      (hs) => OrderingTerm(expression: hs.score, mode: OrderingMode.desc),
    ])
    ..limit(25);
  final scores = await query.get();
  return Response.json(body: scores.map((score) => score.toJson()).toList());
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

  final score = HighScoresCompanion.insert(
    name: name,
    score: body['score'] as int? ?? 0,
  );
  final db = context.read<AppDatabase>();
  final insertedScore = await db.into(db.highScores).insertReturning(score);

  return Response.json(
    statusCode: HttpStatus.created,
    body: insertedScore.toJson(),
  );
}
