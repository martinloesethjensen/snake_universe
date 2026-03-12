import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_models/shared_models.dart';
import 'package:snake_game/services/api_service.dart';
import 'package:snake_game/snake_game.dart';

class LeaderboardOverlay extends StatefulWidget {
  const LeaderboardOverlay({super.key, required this.game, required this.api});

  final SnakeGame game;
  final ApiService api;

  @override
  State<LeaderboardOverlay> createState() => _LeaderboardOverlayState();
}

class _LeaderboardOverlayState extends State<LeaderboardOverlay> {
  late final Future<List<Score>> _scoresFuture = widget.api.fetchTopScores();

  @override
  Widget build(BuildContext context) {
    final px = GoogleFonts.pressStart2p;
    const neon = Color(0xFF39FF14);
    const gold = Color(0xFFFFD700);

    return Material(
      color: Colors.black.withValues(alpha: 0.94),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Text(
                'LEADERBOARD',
                style: px(
                  textStyle: const TextStyle(color: neon, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: neon),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Score>>(
                  future: _scoresFuture,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(color: neon),
                      );
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          'LOAD FAILED',
                          style: px(
                            textStyle: const TextStyle(
                              color: Color(0xFFFF3366),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    }
                    final scores = snap.data!;
                    if (scores.isEmpty) {
                      return Center(
                        child: Text(
                          'NO SCORES YET',
                          style: px(
                            textStyle: const TextStyle(
                              color: neon,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: scores.length,
                      separatorBuilder: (_, i) => Container(
                        height: 1,
                        color: const Color(0xFF1A3A0A),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      itemBuilder: (ctx, i) {
                        final s = scores[i];
                        final rank = '${(i + 1).toString().padLeft(2, '0')}.';
                        final rankColor = i < 3 ? gold : neon;
                        return Row(
                          children: [
                            Text(
                              rank,
                              style: px(
                                textStyle: TextStyle(
                                  color: rankColor,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s.name.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: px(
                                  textStyle: const TextStyle(
                                    color: Color(0xFFCCCCCC),
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              s.score.toString().padLeft(6, '0'),
                              style: px(
                                textStyle: const TextStyle(
                                  color: neon,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: neon),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: widget.game.closeLeaderboard,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: neon),
                    color: Colors.black,
                  ),
                  child: Text(
                    '[ CLOSE ]',
                    style: px(
                      textStyle: const TextStyle(color: neon, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
