/// Responsive grid layout computed from actual canvas dimensions.
///
/// Portrait / mobile  → 15 fixed columns, rows fill the height.
/// Landscape / desktop → 20 fixed rows,   columns fill the width.
///
/// The HUD strip height absorbs any leftover pixels so the layout is
/// pixel-perfect (no gap between grid and HUD).
class GameLayout {
  const GameLayout({
    required this.cols,
    required this.rows,
    required this.cell,
    required this.hudHeight,
  });

  final int cols;
  final int rows;
  final double cell;
  final double hudHeight;

  double get gridW => cols * cell;
  double get gridH => rows * cell;

  /// Compute the best layout for a canvas of [w] × [h] physical pixels.
  factory GameLayout.forCanvas(double w, double h) {
    const minHud = 40.0;
    if (h > w) {
      // Portrait / mobile: 15 columns, rows fill remaining height.
      const cols = 15;
      final cell = w / cols;
      final rows = ((h - minHud) / cell).floor().clamp(10, 60);
      final hudHeight = h - rows * cell; // ≥ minHud by construction
      return GameLayout(
        cols: cols,
        rows: rows,
        cell: cell,
        hudHeight: hudHeight,
      );
    } else {
      // Landscape / desktop: 20 rows, columns fill width.
      const rows = 20;
      final cell = ((h - minHud) / rows).clamp(16.0, 48.0);
      final cols = (w / cell).floor().clamp(10, 60);
      final hudHeight = h - rows * cell;
      return GameLayout(
        cols: cols,
        rows: rows,
        cell: cell,
        hudHeight: hudHeight,
      );
    }
  }

  /// Returns true when the grid dimensions are unchanged (ignoring cell size
  /// micro-changes from continuous window resizing).
  bool sameGrid(GameLayout other) => cols == other.cols && rows == other.rows;
}
