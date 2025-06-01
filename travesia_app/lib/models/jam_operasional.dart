// JamOperasional Model
class JamOperasional {
  final String hari;
  final String jamBuka;
  final String jamTutup;

  JamOperasional({
    required this.hari,
    required this.jamBuka,
    required this.jamTutup,
  });

  factory JamOperasional.fromJson(Map<String, dynamic> json) {
    return JamOperasional(
      hari: json['hari'] as String,
      jamBuka: json['jam_buka'] as String,
      jamTutup: json['jam_tutup'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hari': hari,
      'jam_buka': jamBuka,
      'jam_tutup': jamTutup,
    };
  }
}
