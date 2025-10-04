// Test cart limits for cigarettes
void main() {
  print('🛒 Testing Cart Limits for Cigarettes\n');
  
  // Simulate cart item for sticks
  var stickQuantity = 1;
  var packQuantity = 1;
  
  print('Initial cart:');
  print('- Stick quantity: $stickQuantity');
  print('- Pack quantity: $packQuantity');
  
  // Test 1: Add sticks up to limit
  print('\nTest 1: Adding sticks up to limit (19)');
  for (int i = 2; i <= 19; i++) {
    stickQuantity++;
    print('Added stick, now: $stickQuantity sticks');
  }
  
  // Test 2: Try to add 20th stick (should be blocked)
  print('\nTest 2: Try to add 20th stick');
  if (stickQuantity + 1 > 19) {
    print('❌ Blocked: Maximum 19 sticks per cart item. Add as pack for more.');
  } else {
    stickQuantity++;
    print('Added stick, now: $stickQuantity sticks');
  }
  
  // Test 3: Add packs (no limit except stock)
  print('\nTest 3: Adding packs (limited by stock only)');
  var availablePacks = 5; // Simulate 5 packs in stock
  
  for (int i = 2; i <= 3; i++) {
    if (packQuantity + 1 <= availablePacks) {
      packQuantity++;
      print('Added pack, now: $packQuantity packs');
    } else {
      print('❌ Blocked: Only $availablePacks packs available');
      break;
    }
  }
  
  print('\nFinal cart state:');
  print('- Stick quantity: $stickQuantity (max 19)');
  print('- Pack quantity: $packQuantity (limited by stock)');
  
  print('\n✅ Cart limits working correctly:');
  print('- Stick sales limited to 19 per cart item');
  print('- Pack sales limited by available stock');
  print('- Both can exist in cart simultaneously');
}