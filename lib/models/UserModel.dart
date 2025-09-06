class UserModel {
  final String id;
  final String name;
  final String avatarUrl;

  UserModel({required this.id, required this.name, required this.avatarUrl});

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? 'No Name',
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }
}
