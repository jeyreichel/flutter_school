import '../models/article.dart';
import '../models/commande.dart';
import '../models/historique_utlisateur_commande.dart';
import '../models/user.dart';

class UserService {
  User? loginUser(String email, String password, List<User> users) {
    // Find the user with matching email and password
    User? loggedInUser;
    try {
      loggedInUser = users.firstWhere((user) =>
          user.email.toLowerCase() == email &&
          user.password.toLowerCase() == password);
    } catch (e) {
      loggedInUser = null;
    }
    return loggedInUser;
  }

  // List<User> getUsersByRole(List<User> users, UserRole role) {
  //   return users.where((user) => user.role == role).toList();
  // }
  List<User> getUsers(List<User> users,
      {String? nom, String? prenom, String? role}) {
    List<User> filteredUsers = users;

    if (nom != null) {
      filteredUsers = filteredUsers
          .where((user) => user.nom.toLowerCase() == nom.toLowerCase())
          .toList();
    }

    if (prenom != null) {
      filteredUsers = filteredUsers
          .where((user) => user.prenom.toLowerCase() == prenom.toLowerCase())
          .toList();
    }

    if (role != null) {
      filteredUsers = filteredUsers
          .where((user) => user.role.toLowerCase() == role.toLowerCase())
          .toList();
    }

    return filteredUsers;
  }

  static List<HistoriqueCommande> historiquesDeCommandes = [
    HistoriqueCommande(
      userId: '501235',
      articles: [
        CartItem(
          title: 'Titre de l\'article 1',
          price: '10.0',
          quantity: 2,
        ),

// Deuxième article
        CartItem(
          title: 'Titre de l\'article 2',
          price: '15.0',
          quantity: 1,
        ),

// Troisième article
        CartItem(
          title: 'Titre de l\'article 3',
          price: '20.0',
          quantity: 3,
        ),
      ],
      articlesCommande: [],
      total: null!,
      date: DateTime(2023, 6, 30),
    ),
  ];
  List<User> _userList = [
    User(
      id: 501235,
      nom: 'Nada',
      prenom: 'delly',
      email: 'nada@gmail.com',
      password: '123456',
      role: 'admin',
    ),
    User(
      id: 501234,
      nom: 'Chaima',
      prenom: 'klaii',
      email: 'chaima@gmail.com',
      password: '123456789',
      role: 'responsable',
    ),
    User(
      nom: 'Bouaiin',
      prenom: 'Fraj ',
      role: 'Gerant',
      id: 501237,
      email: 'fraj@gmail.com',
      password: '12345678900',
    ),
    // Add more initial articles here
  ];

  // Méthode pour récupérer la liste d'articles
  List<User> getUser() {
    return _userList;
  }

  void addUser(User user) {
    // Add the new article to the list of articles
    _userList.add(user);
  }

  void updateUser(User updatedUser) {
    int index = _userList.indexWhere((user) => user.id == updatedUser.id);

    if (index != -1) {
      _userList[index].nom = updatedUser.nom;
      _userList[index].prenom = updatedUser.prenom;
      _userList[index].role = updatedUser.role;
      _userList[index].email = updatedUser.email;
      _userList[index].password = updatedUser.password;
    }
  }

}
