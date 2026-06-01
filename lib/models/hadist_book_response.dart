class HadistBook {
  final String name;
  final String id;
  final int available;

  HadistBook({
    required this.name,
    required this.id,
    required this.available,
  });

  factory HadistBook.fromJson(Map<String, dynamic> json) {
    return HadistBook(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      available: json['available'] ?? 0,
    );
  }
}
