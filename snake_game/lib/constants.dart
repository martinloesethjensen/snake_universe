/// Grid dimensions and sizing constants shared across all components.
const int kCols = 20;
const int kRows = 20;
const double kCell = 24.0; // pixels per grid cell (virtual resolution)
const double kHudHeight = 40.0; // height of the score bar below the grid

const double kGameW = kCols * kCell; // 480
const double kGameH = kRows * kCell + kHudHeight; // 520
