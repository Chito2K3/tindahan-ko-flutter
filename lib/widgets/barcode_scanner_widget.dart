import 'package:flutter/material.dart';
import '../services/barcode_service.dart';
import '../utils/theme.dart';

class BarcodeScannerButton extends StatelessWidget {
  final Function(String) onBarcodeDetected;
  final String? tooltip;
  final IconData? icon;
  final Color? color;
  final double? size;

  const BarcodeScannerButton({
    super.key,
    required this.onBarcodeDetected,
    this.tooltip,
    this.icon,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppTheme.primaryPink,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppTheme.primaryPink).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => _scanBarcode(context),
        icon: Icon(
          icon ?? Icons.qr_code_scanner,
          color: Colors.white,
          size: size ?? 24,
        ),
        tooltip: tooltip ?? 'Scan Barcode',
      ),
    );
  }

  void _scanBarcode(BuildContext context) {
    BarcodeService.showBarcodeScanner(
      context,
      title: 'Scan Barcode',
      onBarcodeDetected: onBarcodeDetected,
    );
  }
}

class QuickScanFAB extends StatelessWidget {
  final Function(String) onBarcodeDetected;
  final String? label;

  const QuickScanFAB({
    super.key,
    required this.onBarcodeDetected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _scanBarcode(context),
      backgroundColor: AppTheme.primaryPink,
      icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
      label: Text(
        label ?? 'Quick Scan',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _scanBarcode(BuildContext context) {
    BarcodeService.showBarcodeScanner(
      context,
      title: 'Quick Scan',
      onBarcodeDetected: onBarcodeDetected,
    );
  }
}