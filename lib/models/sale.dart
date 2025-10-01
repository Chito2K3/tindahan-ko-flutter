class Sale {
  final String id;
  final DateTime date;
  final double total;
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.date,
    required this.total,
    required this.items,
  });
}

class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;
}