import 'article.dart';

class Commande {
  final List<CartItem> items;
  String id;
  String userId;
  String num_table;
  DateTime date_cmnd;
  String totale;
  String article_ref;
  String quantite;

  Commande({
    required this.items,
    required this.id,
    required this.userId,
    required this.num_table,
    required this.date_cmnd,
    required this.totale,
    required this.article_ref,
    required this.quantite,
  });

 // Créez une méthode pour convertir les données JSON en objet User
  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'],
      items: json['items'],
      num_table: json['num_table'],
      date_cmnd: json['date_cmnd'],
      totale: json['totale'],
      article_ref: json['article_ref'],
      quantite: json['quantite'], userId: '',
    );
  }

  // Créez une méthode pour convertir l'objet User en données JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'id': id,
      'userId': userId,
      'num_table': num_table,
      'date_cmnd': date_cmnd,
      'totale': totale,
      'article_ref': article_ref,
      'quantite': quantite,
    };
  }
}
class CartItem {
   String title;
   String price;
   int quantity;

  CartItem({
    required this.title,
    required this.price,
    required this.quantity,
  });
}
enum FieldToUpdate {
  Quantity,
  Price,
  Discount,
}
