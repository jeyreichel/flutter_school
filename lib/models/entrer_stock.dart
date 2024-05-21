import 'article.dart';

class StockItem {
  final String designation;
  final String fournisseur;
  int stock;
  double prix;
  DateTime date;

  StockItem(
      {required this.designation,
      required this.fournisseur,
      required this.stock,
      required this.prix,
      required this.date});
}

class StockEntryReceipt {
  String reference;
  String fournisseur;
  DateTime date;
  List<Article> articles; // List of articles in the receipt
  double total;

  StockEntryReceipt({
    required this.reference,
    required this.fournisseur,
    required this.date,
    required this.articles,
    required this.total,
  });
}

class StockEntryArticle {
  String designation;
  double prix;
  int stock;

  StockEntryArticle({
    required this.designation,
    required this.prix,
    required this.stock,
  });
}
