import 'lib/models/product.dart';

void main() {
  print('Testing Cigarette Inventory Logic\n');
  
  // Create a cigarette product with 3 packs
  final winston = Product(
    id: 'winston',
    name: 'Winston',
    price: 10.0, // per stick
    stock: 0, // not used for cigarettes
    category: 'cigarettes',
    emoji: '🚬',
    reorderLevel: 5,
    hasBarcode: true,
    barcode: '1234567890',
    isCigarette: true,
    piecesPerPack: 20,
    packPrice: 190.0,
    packStock: 3, // 3 packs available
  );
  
  print('Initial state:');
  print('Pack stock: ${winston.packStock}');
  print('Stick buffer: ${winston.stickBuffer}');
  print('Total sticks available: ${winston.totalPieces}');
  print('Stock display: ${winston.stockDisplay}\n');
  
  // Test 1: Sell 1 pack
  print('Test 1: Selling 1 pack');
  winston.sellPacks(1);
  print('After selling 1 pack:');
  print('Pack stock: ${winston.packStock}');
  print('Stick buffer: ${winston.stickBuffer}');
  print('Stock display: ${winston.stockDisplay}\n');
  
  // Test 2: Sell 5 sticks (should open 1 pack)
  print('Test 2: Selling 5 sticks');
  winston.sellSticks(5);
  print('After selling 5 sticks:');
  print('Pack stock: ${winston.packStock}');
  print('Stick buffer: ${winston.stickBuffer}');
  print('Stock display: ${winston.stockDisplay}\n');
  
  // Test 3: Sell 15 more sticks (should use remaining buffer)
  print('Test 3: Selling 15 more sticks');
  winston.sellSticks(15);
  print('After selling 15 more sticks:');
  print('Pack stock: ${winston.packStock}');
  print('Stick buffer: ${winston.stickBuffer}');
  print('Stock display: ${winston.stockDisplay}\n');
  
  // Test 4: Sell 25 sticks (should open another pack and use some)
  print('Test 4: Selling 25 sticks');
  winston.sellSticks(25);
  print('After selling 25 sticks:');
  print('Pack stock: ${winston.packStock}');
  print('Stick buffer: ${winston.stickBuffer}');
  print('Stock display: ${winston.stockDisplay}\n');
  
  // Test 5: Check availability
  print('Test 5: Checking availability');
  print('Can sell 10 sticks? ${winston.canSellSticks(10)}');
  print('Can sell 1 pack? ${winston.canSellPacks(1)}');
  print('Can sell 2 packs? ${winston.canSellPacks(2)}');
}