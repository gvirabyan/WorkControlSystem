class UserModel {
  final String id;
  final String name;
  final String position;
  final String avatarUrl;

  UserModel({required this.id, required this.name,required this.position, required this.avatarUrl});

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? 'No Name',
      position: data['position'] ?? 'No position',
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }
}
