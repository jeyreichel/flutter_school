import 'article.dart';
import 'commande.dart';

class HistoriqueCommande {
  late final List<Article> articlesCommande;
  final String userId;
  final List<CartItem> articles;
  final double total;
  final DateTime date;

  HistoriqueCommande({
    required this.userId,
    required this.articles,
    required this.articlesCommande,
    required this.total,
    required this.date,
  });
}
