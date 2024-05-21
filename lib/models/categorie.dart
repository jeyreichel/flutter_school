class Categorie {
  String id;
  String name;
  String reference;
  String imageUrl;

  Categorie({
    required this.id,
    required this.name,
    required this.reference,
    required this.imageUrl,
  });

  // Constructeur fromJson pour créer une instance de Categorie à partir des données JSON
  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'],
      name: json['name'],
      reference: json['reference'],
      imageUrl: json['imageUrl'],
    );
  }
}
