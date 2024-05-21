import '../models/article.dart';
import '../models/entrer_stock.dart';

class StockEntryReceiptService {
  String getValueFromAttribute(StockEntryReceipt stockEntryReceipt, String attribute) {
    switch (attribute) {
      case 'reference':
        return stockEntryReceipt.reference;
      case 'fournisseur':
        return stockEntryReceipt.fournisseur;
      case 'date':
        return stockEntryReceipt.date.timeZoneName;
      case 'nbr articles':
        return stockEntryReceipt.articles.length.toString();
      case 'total':
        return stockEntryReceipt.total.toString();
      default:
        return ''; // Valeur par défaut
    }
  }

}