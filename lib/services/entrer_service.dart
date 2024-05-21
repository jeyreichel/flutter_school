import '../models/entrer.dart';

class EntrerService {
  List<Entrer> _entrersList = [
    Entrer(
      numero: 12,
      date: DateTime(2023, 6, 30),
      user_name: 'test',
      categorie_id: 'Pizza',
      cout_totale: 2200,
      montant_total: 5000,
    ),
    Entrer(
      numero: 1,
      date: DateTime(2023, 7, 30),
      user_name: 'Nada',
      categorie_id: 'Pizza',
      cout_totale: 200,
      montant_total: 7000,
    ),
  ];

  List<Entrer> getEntrer() {
    return _entrersList;
  }

  void addEntrer(Entrer entrer) {
    _entrersList.add(entrer);
  }
}
