/// An exercise from the platform library `GET /exercises` (also the shape
/// returned by `POST /exercises` when a trainer adds a custom one).
///
/// Searchable by name / category / equipment server-side.
class Exercise {
  final String id;
  final String name;

  /// Category / muscle group (e.g. `CHEST`, `LEGS`, `FULL_BODY`).
  final String? category;

  /// Muscle group synonym the backend may expose.
  final String? muscleGroup;

  final String? equipment;
  final String? description;
  final String? difficulty;

  /// True if a trainer (not the platform) created it.
  final bool isCustom;
  final String? createdBy;

  const Exercise({
    required this.id,
    required this.name,
    this.category,
    this.muscleGroup,
    this.equipment,
    this.description,
    this.difficulty,
    this.isCustom = false,
    this.createdBy,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      muscleGroup: json['muscleGroup'] as String?,
      equipment: json['equipment'] as String?,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String?,
      isCustom: json['isCustom'] as bool? ?? json['source'] == 'TRAINER',
      createdBy: json['createdBy'] as String?,
    );
  }

  /// Body for `POST /exercises`.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (category != null) 'category': category,
      if (muscleGroup != null) 'muscleGroup': muscleGroup,
      if (equipment != null) 'equipment': equipment,
      if (description != null) 'description': description,
      if (difficulty != null) 'difficulty': difficulty,
    };
  }
}