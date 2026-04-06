class Trainee {
  final int? id;
  final String name;
  final String? notes;
  final int createdAt;

  const Trainee({
    this.id,
    required this.name,
    this.notes,
    required this.createdAt,
  });

  DateTime get createdAtDate =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);

  factory Trainee.fromMap(Map<String, dynamic> map) => Trainee(
        id: map['id'] as int?,
        name: map['name'] as String,
        notes: map['notes'] as String?,
        createdAt: map['created_at'] as int,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'notes': notes,
        'created_at': createdAt,
      };

  Trainee copyWith({
    int? id,
    String? name,
    String? notes,
    int? createdAt,
  }) =>
      Trainee(
        id: id ?? this.id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}
