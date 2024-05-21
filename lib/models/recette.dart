// Modèle pour représenter une recette
class Recette {
  String caisse;
  double totalPaiement;
  double total;
  DateTime date;
  String etat;
  DateTime tempsCloture;
  String utilisateurCloture;

  Recette({
    required this.caisse,
    required this.totalPaiement,
    required this.total,
    required this.date,
    required this.etat,
    required this.tempsCloture,
    required this.utilisateurCloture,
  });
}