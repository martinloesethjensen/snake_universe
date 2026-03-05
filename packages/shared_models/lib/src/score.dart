class Score {
  const Score({required this.name, required this.score});
  final String name;
  final int score;

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(name: json['name'] as String, score: json['score'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'score': score};
  }
}
