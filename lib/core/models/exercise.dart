class Exercise {
  final int? id;
  final String name;
  final String? category;    // movement pattern: Push, Pull, Hinge, Squat…
  final String? muscleFocus; // primary muscles: Chest, Quads, Hamstrings…
  final String language;     // 'en' or 'es'
  final int createdAt;

  const Exercise({
    this.id,
    required this.name,
    this.category,
    this.muscleFocus,
    this.language = 'en',
    required this.createdAt,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'] as int?,
        name: map['name'] as String,
        category: map['category'] as String?,
        muscleFocus: map['muscle_focus'] as String?,
        language: map['language'] as String? ?? 'en',
        createdAt: map['created_at'] as int,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'category': category,
        'muscle_focus': muscleFocus,
        'language': language,
        'created_at': createdAt,
      };

  Exercise copyWith({
    int? id,
    String? name,
    String? category,
    String? muscleFocus,
    String? language,
    int? createdAt,
  }) =>
      Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        muscleFocus: muscleFocus ?? this.muscleFocus,
        language: language ?? this.language,
        createdAt: createdAt ?? this.createdAt,
      );
}
