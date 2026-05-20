class User {
  const User({required this.name, required this.email});

  final String name;
  final String email;

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] as String,
    email: json['email'] as String,
  );

  Map<String, dynamic> toJson() => {'name': name, 'email': email};

  User copyWith({String? name, String? email}) =>
      User(name: name ?? this.name, email: email ?? this.email);
}
