class AllergyOption {
  final int id;
  final String name;
  final String? type;

  const AllergyOption({
    required this.id,
    required this.name,
    this.type,
  });

  factory AllergyOption.fromJson(Map<String, dynamic> json) {
    return AllergyOption(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (type != null) 'type': type,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AllergyOption &&
      other.id == id &&
      other.name == name &&
      other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ type.hashCode;
}
