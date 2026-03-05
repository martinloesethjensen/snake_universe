import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_models/shared_models.dart';
import 'package:snake_game/services/api_service.dart';
import 'package:snake_game/snake_game.dart';

class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key, required this.game});

  final SnakeGame game;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  final _nameController = TextEditingController();
  final _api = ApiService();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'ENTER YOUR NAME!');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _api.submitScore(Score(name: name, score: widget.game.finalScore));
      widget.game.openLeaderboard();
    } catch (_) {
      setState(() {
        _error = 'SUBMIT FAILED. TRY AGAIN.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final px = GoogleFonts.pressStart2p;
    return Material(
      color: Colors.black.withValues(alpha: 0.88),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME  OVER',
                style: px(
                  textStyle: const TextStyle(
                    color: Color(0xFFFF3366),
                    fontSize: 22,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SCORE: ${widget.game.finalScore}',
                style: px(
                  textStyle: const TextStyle(
                    color: Color(0xFF39FF14),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: TextField(
                  controller: _nameController,
                  autofocus: true,
                  maxLength: 16,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  style: px(
                    textStyle: const TextStyle(
                      color: Color(0xFF39FF14),
                      fontSize: 12,
                    ),
                  ),
                  cursorColor: const Color(0xFF39FF14),
                  decoration: InputDecoration(
                    hintText: 'ENTER NAME',
                    hintStyle: px(
                      textStyle: const TextStyle(
                        color: Color(0xFF2A6010),
                        fontSize: 12,
                      ),
                    ),
                    counterStyle: const TextStyle(
                      color: Colors.transparent,
                      height: 0,
                    ),
                    filled: true,
                    fillColor: Colors.black,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF39FF14)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF39FF14),
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: px(
                    textStyle: const TextStyle(
                      color: Color(0xFFFF3366),
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_submitting)
                const CircularProgressIndicator(color: Color(0xFF39FF14))
              else
                _RetroButton(
                  label: '[ SUBMIT ]',
                  onTap: _submit,
                  style: px(
                    textStyle: const TextStyle(
                      color: Color(0xFF39FF14),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _RetroButton(
                label: '[ PLAY AGAIN ]',
                onTap: widget.game.restart,
                style: px(
                  textStyle: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 10,
                  ),
                ),
                borderColor: const Color(0xFF555555),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetroButton extends StatelessWidget {
  const _RetroButton({
    required this.label,
    required this.onTap,
    required this.style,
    this.borderColor = const Color(0xFF39FF14),
  });

  final String label;
  final VoidCallback onTap;
  final TextStyle style;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          color: Colors.black,
        ),
        child: Text(label, style: style),
      ),
    );
  }
}
