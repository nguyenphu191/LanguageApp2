class UserModel {
  final int id;
  final String username;
  final String email;
  final String password;
  final String firtname;
  final String lastname;
  final String profile_image_url;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.firtname,
    required this.lastname,
    required this.profile_image_url,
    required this.role,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      firtname: json['firtname'],
      lastname: json['lastname'],
      profile_image_url: json['profile_image_url'],
      role: json['role'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'firtname': firtname,
      'lastname': lastname,
      'profile_image_url': profile_image_url,
      'role': role,
    };
  }
}
