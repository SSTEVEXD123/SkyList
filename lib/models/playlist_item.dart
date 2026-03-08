class PlaylistItem {
  const PlaylistItem({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
  });

  final String id;
  final String name;
  final List<int> songIds;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'songIds': songIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PlaylistItem.fromMap(Map<String, dynamic> map) {
    return PlaylistItem(
      id: map['id'] as String,
      name: map['name'] as String,
      songIds: (map['songIds'] as List<dynamic>).map((e) => e as int).toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
