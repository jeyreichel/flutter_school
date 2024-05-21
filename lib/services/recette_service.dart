import '../models/recette.dart';

class RecetteService {
  // Liste de recettes (simulée pour démonstration)
  List<Recette> _recettes = [
    Recette(
      caisse: 'Caisse 1',
      totalPaiement: 500.0,
      total: 1000.0,
      date: DateTime(2023, 6, 30),
      etat: 'Ouverte',
      tempsCloture: DateTime(2023, 7, 30, 18, 30),
      utilisateurCloture: 'Nada Delly',
    ),
    Recette(
      caisse: 'Caisse 2',
      totalPaiement: 800.0,
      total: 1500.0,
      date: DateTime(2023, 5, 29),
      etat: 'Clôturée',
      tempsCloture: DateTime(2023, 7, 29, 19, 15),
      utilisateurCloture: 'Chaima Klaii',
    ),
    Recette(
      caisse: 'Caisse 3',
      totalPaiement: 500.0,
      total: 1200.0,
      date: DateTime(2023, 5, 1),
      etat: 'Clôturée',
      tempsCloture: DateTime(2023, 7, 3, 17, 15),
      utilisateurCloture: 'Fraj Bouaiin',
    ),
    Recette(
      caisse: 'Caisse 4',
      totalPaiement: 700.0,
      total: 3200.0,
      date: DateTime(2023, 5, 19),
      etat: 'Clôturée',
      tempsCloture: DateTime(2023, 7, 1, 17, 15),
      utilisateurCloture: 'Meriam Mrabet',
    ),
    // Ajoutez plus de recettes ici
  ];

  // Fonction pour récupérer toutes les recettes
  List<Recette> getRecettes() {
    return _recettes;
  }

// Vous pouvez ajouter d'autres fonctions ici pour gérer les recettes, telles que :
// - Ajouter une nouvelle recette
// - Mettre à jour une recette existante
// - Supprimer une recette
}