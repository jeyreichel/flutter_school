class User {
  int id;
  String nom;
  String prenom;
  String email;
  String password;
  String role;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  // Add a factory constructor to convert a map back into a User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }
}
