class Province {
  final String id;
  final String name;
  final String code;
  final String image;

  Province({
    required this.id,
    required this.name,
    required this.code,
    required this.image,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'image': image,
    };
  }
}
