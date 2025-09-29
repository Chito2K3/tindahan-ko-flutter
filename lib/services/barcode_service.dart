import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

class BarcodeService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  static void showBarcodeScanner(
    BuildContext context, {
    required Function(String) onBarcodeDetected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BarcodeScanner(
        onBarcodeDetected: onBarcodeDetected,
      ),
    );
  }
}

class BarcodeScanner extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const BarcodeScanner({
    super.key,
    required this.onBarcodeDetected,
  });

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📱 Barcode Scanner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => controller.toggleTorch(),
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Scanner View
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    if (!isScanning) return;
                    
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _onBarcodeFound(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
                
                // Overlay
                Container(
                  decoration: ShapeDecoration(
                    shape: QrScannerOverlayShape(
                      borderColor: const Color(0xFFFF69B4),
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 250,
                    ),
                  ),
                ),
                
                // Instructions
                const Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Align barcode within the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Manual Input
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Or type barcode manually...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _onBarcodeFound(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Handle manual input
                  },
                  child: const Text('✓'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onBarcodeFound(String barcode) {
    if (!isScanning) return;
    
    setState(() {
      isScanning = false;
    });
    
    // Vibrate and close
    Vibration.vibrate(duration: 100);
    Navigator.pop(context);
    widget.onBarcodeDetected(barcode);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _borderLength = borderLength > cutOutSize / 2 + borderWidth * 2
        ? borderWidthSize / 2
        : borderLength;
    final _cutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
          RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
          boxPaint)
      ..restore();

    // Draw corner borders
    final path = Path()
      ..moveTo(cutOutRect.left - borderOffset, cutOutRect.top + _borderLength)
      ..lineTo(cutOutRect.left - borderOffset, cutOutRect.top + borderRadius)
      ..quadraticBezierTo(cutOutRect.left - borderOffset, cutOutRect.top - borderOffset,
          cutOutRect.left + borderRadius, cutOutRect.top - borderOffset)
      ..lineTo(cutOutRect.left + _borderLength, cutOutRect.top - borderOffset);

    canvas.drawPath(path, borderPaint);

    // Top right corner
    final path2 = Path()
      ..moveTo(cutOutRect.right - _borderLength, cutOutRect.top - borderOffset)
      ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top - borderOffset)
      ..quadraticBezierTo(cutOutRect.right + borderOffset, cutOutRect.top - borderOffset,
          cutOutRect.right + borderOffset, cutOutRect.top + borderRadius)
      ..lineTo(cutOutRect.right + borderOffset, cutOutRect.top + _borderLength);

    canvas.drawPath(path2, borderPaint);

    // Bottom right corner
    final path3 = Path()
      ..moveTo(cutOutRect.right + borderOffset, cutOutRect.bottom - _borderLength)
      ..lineTo(cutOutRect.right + borderOffset, cutOutRect.bottom - borderRadius)
      ..quadraticBezierTo(cutOutRect.right + borderOffset, cutOutRect.bottom + borderOffset,
          cutOutRect.right - borderRadius, cutOutRect.bottom + borderOffset)
      ..lineTo(cutOutRect.right - _borderLength, cutOutRect.bottom + borderOffset);

    canvas.drawPath(path3, borderPaint);

    // Bottom left corner
    final path4 = Path()
      ..moveTo(cutOutRect.left + _borderLength, cutOutRect.bottom + borderOffset)
      ..lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom + borderOffset)
      ..quadraticBezierTo(cutOutRect.left - borderOffset, cutOutRect.bottom + borderOffset,
          cutOutRect.left - borderOffset, cutOutRect.bottom - borderRadius)
      ..lineTo(cutOutRect.left - borderOffset, cutOutRect.bottom - _borderLength);

    canvas.drawPath(path4, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}