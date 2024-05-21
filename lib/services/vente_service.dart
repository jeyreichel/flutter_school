import '../models/vente.dart';

class VenteService {
  List<Vente> getVentes() {
    // Ici, vous pouvez récupérer la liste des ventes à partir de votre source de données (base de données, API, etc.)
    // Pour cet exemple, nous allons simplement créer des ventes fictives.
    return [
      Vente(
        caisse: 'Caisse 1',
        totalPaiement: 100.0,
        total: 120.0,
        date: DateTime(2023, 7, 30),
        etat: 'En cours',
        utilisateur: 'Utilisateur 1',
      ),
      Vente(
        caisse: 'Caisse 2',
        totalPaiement: 100.0,
        total: 120.0,
        date: DateTime(2023, 6, 30),
        etat: 'En cours',
        utilisateur: 'Utilisateur 2',
      ),
      Vente(
        caisse: 'Caisse 3',
        totalPaiement: 100.0,
        total: 120.0,
        date: DateTime(2023, 8, 30),
        etat: 'En cours',
        utilisateur: 'Utilisateur 3',
      ),
      // Ajoutez d'autres ventes fictives ici...
    ];
  }
}
