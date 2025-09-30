import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class BarcodeService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Pre-load beep sound for faster playback
      await _audioPlayer.setSource(AssetSource('sounds/beep.mp3'));
      _isInitialized = true;
    } catch (e) {
      debugPrint('Audio initialization failed: $e');
    }
  }

  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;
    
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  static Future<void> playBeepSound() async {
    try {
      await _audioPlayer.resume();
      // Vibration feedback
      // if (await Vibration.hasVibrator() ?? false) {
      //   Vibration.vibrate(duration: 100);
      // }
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Beep sound failed: $e');
      // Fallback to system sound
      HapticFeedback.lightImpact();
    }
  }

  static void showBarcodeScanner(
    BuildContext context, {
    required Function(String) onBarcodeDetected,
    String? title,
    bool allowManualInput = true,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScanner(
          onBarcodeDetected: onBarcodeDetected,
          title: title ?? 'Scan Barcode',
          allowManualInput: allowManualInput,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class BarcodeScanner extends StatefulWidget {
  final Function(String) onBarcodeDetected;
  final String title;
  final bool allowManualInput;

  const BarcodeScanner({
    super.key,
    required this.onBarcodeDetected,
    required this.title,
    this.allowManualInput = true,
  });

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner>
    with TickerProviderStateMixin {
  MobileScannerController? _controller;
  final TextEditingController _textController = TextEditingController();
  
  bool _isScanning = true;
  bool _hasPermission = false;
  bool _isFlashOn = false;
  bool _showManualInput = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _initializeScanner();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initializeScanner() async {
    await BarcodeService.initialize();
    
    final hasPermission = await BarcodeService.requestCameraPermission();
    setState(() {
      _hasPermission = hasPermission;
    });

    if (hasPermission) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        actions: [
          if (_hasPermission) ...[
            IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: _isFlashOn ? Colors.yellow : Colors.white,
              ),
            ),
          ],
          if (widget.allowManualInput)
            IconButton(
              onPressed: () => setState(() => _showManualInput = !_showManualInput),
              icon: Icon(
                _showManualInput ? Icons.camera_alt : Icons.keyboard,
                color: Colors.white,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Scanner or Placeholder
          if (_hasPermission && !_showManualInput)
            _buildCameraScanner()
          else
            _buildScannerPlaceholder(),
          
          // Scanning Overlay
          if (!_showManualInput) _buildScanningOverlay(),
          
          // Manual Input
          if (_showManualInput) _buildManualInput(),
          
          // Instructions
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildCameraScanner() {
    return MobileScanner(
      controller: _controller,
      onDetect: _onBarcodeDetected,
    );
  }

  Widget _buildScannerPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 120,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Grant camera access to scan barcodes',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final hasPermission = await BarcodeService.requestCameraPermission();
                setState(() {
                  _hasPermission = hasPermission;
                });
                if (hasPermission) {
                  _controller = MobileScannerController(
                    detectionSpeed: DetectionSpeed.noDuplicates,
                    facing: CameraFacing.back,
                    torchEnabled: false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF69B4),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Grant Camera Permission',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return CustomPaint(
      painter: ScannerOverlayPainter(
        scanLineAnimation: _scanLineController,
        borderColor: const Color(0xFFFF69B4),
      ),
      child: Container(),
    );
  }

  Widget _buildManualInput() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.keyboard,
              size: 64,
              color: Color(0xFFFF69B4),
            ),
            const SizedBox(height: 24),
            const Text(
              'Manual Barcode Entry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter barcode number...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF69B4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF69B4), width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _onBarcodeFound(value);
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    _onBarcodeFound(_textController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF69B4),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Barcode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    if (_showManualInput) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Position barcode within the frame\nScanning will happen automatically',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      _onBarcodeFound(barcode!.rawValue!);
    }
  }

  void _onBarcodeFound(String barcode) {
    // Prevent duplicate scans within 2 seconds
    final now = DateTime.now();
    if (_lastScannedCode == barcode && 
        _lastScanTime != null && 
        now.difference(_lastScanTime!).inSeconds < 2) {
      return;
    }
    
    if (!_isScanning) return;
    
    setState(() {
      _isScanning = false;
      _lastScannedCode = barcode;
      _lastScanTime = now;
    });
    
    // Play beep sound and vibrate
    BarcodeService.playBeepSound();
    
    // Show success feedback
    _showSuccessFeedback(barcode);
    
    // Close scanner after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onBarcodeDetected(barcode);
      }
    });
  }

  void _showSuccessFeedback(String barcode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Barcode Scanned!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                barcode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFlash() {
    if (_controller != null) {
      _controller!.toggleTorch();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textController.dispose();
    _scanLineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Animation<double> scanLineAnimation;
  final Color borderColor;
  
  ScannerOverlayPainter({
    required this.scanLineAnimation,
    required this.borderColor,
  }) : super(repaint: scanLineAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Draw overlay with transparent center
    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(centerRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner borders
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cornerLength = 30.0;
    final corners = [
      // Top-left
      [centerRect.topLeft, centerRect.topLeft + Offset(cornerLength, 0)],
      [centerRect.topLeft, centerRect.topLeft + Offset(0, cornerLength)],
      // Top-right
      [centerRect.topRight, centerRect.topRight + Offset(-cornerLength, 0)],
      [centerRect.topRight, centerRect.topRight + Offset(0, cornerLength)],
      // Bottom-left
      [centerRect.bottomLeft, centerRect.bottomLeft + Offset(cornerLength, 0)],
      [centerRect.bottomLeft, centerRect.bottomLeft + Offset(0, -cornerLength)],
      // Bottom-right
      [centerRect.bottomRight, centerRect.bottomRight + Offset(-cornerLength, 0)],
      [centerRect.bottomRight, centerRect.bottomRight + Offset(0, -cornerLength)],
    ];

    for (final corner in corners) {
      canvas.drawLine(corner[0], corner[1], borderPaint);
    }

    // Draw scanning line
    final scanLinePaint = Paint()
      ..color = borderColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final scanY = centerRect.top + 
        (centerRect.height * scanLineAnimation.value);
    
    canvas.drawLine(
      Offset(centerRect.left + 10, scanY),
      Offset(centerRect.right - 10, scanY),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

