class DoaResponse {
  final String id;
  final String judul;
  final String arab;
  final String latin;
  final String arti;

  DoaResponse({
    required this.id,
    required this.judul,
    required this.arab,
    required this.latin,
    required this.arti,
  });

  factory DoaResponse.fromJson(Map<String, dynamic> json) {
    return DoaResponse(
      id: json['id'].toString(),
      judul: (json['doa'] ?? json['nama'] ?? '').toString(),
      arab: (json['ayat'] ?? json['ar'] ?? '').toString(),
      latin: (json['latin'] ?? json['tr'] ?? '').toString(),
      arti: (json['artinya'] ?? json['idn'] ?? '').toString(),
    );
  }
}
