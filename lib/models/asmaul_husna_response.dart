class AsmaulHusna {
  final int index;
  final String latin;
  final String arab;
  final String translation;

  AsmaulHusna({
    required this.index,
    required this.latin,
    required this.arab,
    required this.translation,
  });

  factory AsmaulHusna.fromJson(Map<String, dynamic> json) {
    return AsmaulHusna(
      index: json['urutan'] ?? 0,
      latin: json['latin'] ?? '',
      arab: json['arab'] ?? '',
      translation: json['arti'] ?? '',
    );
  }
}
