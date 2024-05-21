class Vente {
  final String caisse;
  final double totalPaiement;
  final double total;
  final DateTime date;
  final String etat;
  final String utilisateur;

  Vente({
    required this.caisse,
    required this.totalPaiement,
    required this.total,
    required this.date,
    required this.etat,
    required this.utilisateur,
  });
}
