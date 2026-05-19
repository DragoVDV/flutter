class User {
  const User({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };

  User copyWith({String? name, String? email, String? password}) =>
      User(
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
      );
}
