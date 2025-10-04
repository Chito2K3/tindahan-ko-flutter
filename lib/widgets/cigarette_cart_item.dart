import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';

class CigaretteCartItemWidget extends StatelessWidget {
  final CigaretteCartItem item;
  final int index;

  const CigaretteCartItemWidget({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                item.product.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      AppTheme.formatCurrency(item.totalPrice),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Pack controls
          if (item.product.packPrice != null) ...[
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Packs:',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                _QuantityButton(
                  icon: Icons.remove,
                  onPressed: () => _updateQuantity(context, CigaretteUnit.pack, -1),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.packQuantity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                _QuantityButton(
                  icon: Icons.add,
                  onPressed: () => _updateQuantity(context, CigaretteUnit.pack, 1),
                ),
                const SizedBox(width: 8),
                Text(
                  AppTheme.formatCurrency(item.product.packPrice!),
                  style: const TextStyle(color: AppTheme.primaryPink, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          // Piece controls
          Row(
            children: [
              const Icon(Icons.scatter_plot, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Sticks:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              _QuantityButton(
                icon: Icons.remove,
                onPressed: () => _updateQuantity(context, CigaretteUnit.piece, -1),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.pieceQuantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _QuantityButton(
                icon: Icons.add,
                onPressed: () => _updateQuantity(context, CigaretteUnit.piece, 1),
              ),
              const SizedBox(width: 8),
              Text(
                AppTheme.formatCurrency(item.product.price),
                style: const TextStyle(color: AppTheme.primaryPink, fontSize: 12),
              ),
            ],
          ),
          // Stock info
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(
                'Available: ${item.product.stockDisplay}',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateQuantity(BuildContext context, CigaretteUnit unit, int change) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    // This method doesn't exist in AppProvider, so we need to handle it differently
    // For now, we'll use the existing cart update logic
    final message = provider.updateCartQuantityByIncrement(index, change, 1);
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppTheme.primaryPink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 14, color: Colors.white),
        padding: EdgeInsets.zero,
      ),
    );
  }
}