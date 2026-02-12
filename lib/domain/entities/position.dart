class GridPosition {
  const GridPosition(this.row, this.col);

  final int row;
  final int col;

  bool isOrthogonallyAdjacent(GridPosition other) {
    final rowDelta = (row - other.row).abs();
    final colDelta = (col - other.col).abs();
    return rowDelta + colDelta == 1;
  }

  @override
  bool operator ==(Object other) {
    return other is GridPosition && row == other.row && col == other.col;
  }

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row,$col)';
}
