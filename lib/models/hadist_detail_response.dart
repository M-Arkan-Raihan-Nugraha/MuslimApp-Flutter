class HadistDetail {
  final int number;
  final String arab;
  final String translation;

  HadistDetail({
    required this.number,
    required this.arab,
    required this.translation,
  });

  factory HadistDetail.fromJson(Map<String, dynamic> json) {
    return HadistDetail(
      number: json['number'] ?? 0,
      arab: json['arab'] ?? '',
      translation: json['id'] ?? '',
    );
  }
}
