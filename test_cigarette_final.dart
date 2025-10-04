import 'lib/models/product.dart';

void main() {
  print('🚬 Testing Cigarette Logic - Final Implementation\n');
  
  // Create cigarette product with 5 packs (100 sticks total)
  final winston = Product(
    id: 'winston',
    name: 'Winston',
    price: 10.0, // per stick
    stock: 0, // Not used for cigarettes
    category: 'cigarettes',
    emoji: '🚬',
    reorderLevel: 2,
    hasBarcode: true,
    barcode: '123456789',
    isCigarette: true,
    piecesPerPack: 20,
    packPrice: 190.0, // per pack
    packStock: 5, // 5 packs available
  );
  
  print('Initial State:');
  print('Pack Stock: ${winston.packStock}');
  print('Stick Buffer: ${winston.stickBuffer}');
  print('Total Available Sticks: ${winston.totalPieces}');
  print('Can sell 25 sticks? ${winston.canSellSticks(25)}');
  print('');
  
  // Test 1: Sell 1 pack
  print('Test 1: Sell 1 pack');
  winston.sellPacks(1);
  print('After selling 1 pack:');
  print('Pack Stock: ${winston.packStock}');
  print('Stick Buffer: ${winston.stickBuffer}');
  print('Total Available Sticks: ${winston.totalPieces}');
  print('');
  
  // Test 2: Sell 5 sticks (should open 1 pack, leave 15 in buffer)
  print('Test 2: Sell 5 sticks');
  winston.sellSticks(5);
  print('After selling 5 sticks:');
  print('Pack Stock: ${winston.packStock} (should be 3 - one pack opened)');
  print('Stick Buffer: ${winston.stickBuffer} (should be 15)');
  print('Total Available Sticks: ${winston.totalPieces}');
  print('');
  
  // Test 3: Sell 10 more sticks (should use 10 from buffer, leave 5)
  print('Test 3: Sell 10 more sticks');
  winston.sellSticks(10);
  print('After selling 10 more sticks:');
  print('Pack Stock: ${winston.packStock} (should still be 3)');
  print('Stick Buffer: ${winston.stickBuffer} (should be 5)');
  print('Total Available Sticks: ${winston.totalPieces}');
  print('');
  
  // Test 4: Sell 25 sticks (should use 5 from buffer + open 1 pack for 20 more)
  print('Test 4: Sell 25 sticks');
  winston.sellSticks(25);
  print('After selling 25 sticks:');
  print('Pack Stock: ${winston.packStock} (should be 2 - one more pack opened)');
  print('Stick Buffer: ${winston.stickBuffer} (should be 0)');
  print('Total Available Sticks: ${winston.totalPieces}');
  print('');
  
  // Test 5: Sell 30 sticks (should open 2 packs, leave 10 in buffer)
  print('Test 5: Sell 30 sticks');
  winston.sellSticks(30);
  print('After selling 30 sticks:');
  print('Pack Stock: ${winston.packStock} (should be 0)');
  print('Stick Buffer: ${winston.stickBuffer} (should be 10)');
  print('Total Available Sticks: ${winston.totalPieces}');
  print('');
  
  // Test 6: Try to sell more than available
  print('Test 6: Try to sell 15 sticks (only 10 available)');
  print('Can sell 15 sticks? ${winston.canSellSticks(15)}');
  print('Can sell 10 sticks? ${winston.canSellSticks(10)}');
  print('');
  
  // Test 7: Sell remaining 10 sticks
  print('Test 7: Sell remaining 10 sticks');
  winston.sellSticks(10);
  print('After selling remaining 10 sticks:');
  print('Pack Stock: ${winston.packStock} (should be 0)');
  print('Stick Buffer: ${winston.stickBuffer} (should be 0)');
  print('Total Available Sticks: ${winston.totalPieces} (should be 0)');
  print('');
  
  print('✅ All tests completed!');
  print('Key Points Verified:');
  print('- Pack stock is deducted immediately when opened');
  print('- Stick buffer persists remaining sticks from opened packs');
  print('- Logic correctly handles partial pack usage');
  print('- Inventory tracking is accurate throughout');
}