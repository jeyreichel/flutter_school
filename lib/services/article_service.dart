import '../models/article.dart';
import '../models/categorie.dart';

class ArticleService {
  String getValueFromAttribute(Article article, String attribute) {
    switch (attribute) {
      case 'reference':
        return article.reference;
      case 'codeBarre':
        return article.codeBarre;
      case 'designation':
        return article.designation;
      case 'categorie':
        return article.categorie;
      case 'stock':
        return article.stock.toString();
      case 'prix':
        return article.prix.toString();
      default:
        return ''; // Valeur par défaut
    }
  }

  List<Article> _articlesList = [];

  List<Article> getArticles() {
    return _articlesList;
  }

  void addArticle(Article article) {
    _articlesList.add(article);
  }

  List<Article> getArticlesByCategory(String category) {
    return _articlesList
        .where((article) => article.categorie == category)
        .toList();
  }
}

class CategorieService {
  // Private variable to store the list of categories
  List<Categorie> _categoriesList = [];

  // Méthode pour récupérer la liste de catégories
  List<Categorie> getCategories() {
    return _categoriesList;
  }

  // Méthode pour ajouter une nouvelle catégorie à la liste
  void addCategorie(Categorie categorie) {
    // Add the new category to the list of categories
    _categoriesList.add(categorie);
  }
}
