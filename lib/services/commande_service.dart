import 'package:caisse_tectille/models/commande.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/historique_utlisateur_commande.dart';
import '../models/user.dart';

class CommandeService {
  List<Commande> _orders = [];
  List<HistoriqueCommande> historiqueCommandes = [];

  Future<void> passerCommande(List<CartItem> cartItems, String totale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId =prefs.getString('userId' );
    if (userId != null) {
      final newOrder = Commande(
        id: generateUniqueId(),
        userId: userId, // Utilisez l'ID de l'utilisateur récupéré depuis SharedPreferences
        items: cartItems,
        date_cmnd: DateTime.now(),
        totale: totale,
        num_table: '', // Remplissez ces champs selon vos besoins
        article_ref: '', // Remplissez ces champs selon vos besoins
        quantite: '', // Remplissez ces champs selon vos besoins
      );
      _orders.insert(0, newOrder);
      await Future.delayed(Duration(seconds: 2));
    } else {
      // L'ID de l'utilisateur n'est pas disponible dans SharedPreferences
      // Gérez cette situation en conséquence (par exemple, demandez à l'utilisateur de se connecter)
    }
  }

  List<Commande> get orders {
    return [..._orders];
  }
  String generateUniqueId() {
    // Implémentez la logique pour générer un ID unique ici
    // Vous pouvez utiliser des packages externes ou une logique personnalisée
    // Pour l'exemple, nous utilisons un timestamp comme ID
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
