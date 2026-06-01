class QuranSuratDetailResponse {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final List<Ayat> ayat;

  QuranSuratDetailResponse({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.ayat,
  });

  factory QuranSuratDetailResponse.fromJson(Map<String, dynamic> json) {
    return QuranSuratDetailResponse(
      nomor: json['nomor'],
      nama: json['nama'],
      namaLatin: json['namaLatin'],
      jumlahAyat: json['jumlahAyat'],
      tempatTurun: json['tempatTurun'],
      arti: json['arti'],
      ayat: (json['ayat'] as List)
          .map((e) => Ayat.fromJson(e))
          .toList(),
    );
  }
}

class Ayat {
  final int nomorAyat;
  final String arab;
  final String latin;
  final String arti;

  Ayat({
    required this.nomorAyat,
    required this.arab,
    required this.latin,
    required this.arti,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      nomorAyat: json['nomorAyat'],
      arab: json['teksArab'],
      latin: json['teksLatin'],
      arti: json['teksIndonesia'],
    );
  }
}
