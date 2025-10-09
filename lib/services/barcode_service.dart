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
  final Map<String, DateTime> _scannedCodes = {};
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  static const Duration _scanCooldown = Duration(milliseconds: 1500);
  
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
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        returnImage: false,
        detectionTimeoutMs: 1000,
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
          // Clear scanned codes button
          if (_scannedCodes.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _scannedCodes.clear();
                  _lastScannedCode = null;
                  _lastScanTime = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scanned history cleared'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              tooltip: 'Clear scanned history',
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
          
          // Scanned count indicator
          if (_scannedCodes.isNotEmpty && !_showManualInput)
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF69B4).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Scanned: ${_scannedCodes.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
                    detectionSpeed: DetectionSpeed.normal,
                    facing: CameraFacing.back,
                    torchEnabled: false,
                    returnImage: false,
                    detectionTimeoutMs: 1000,
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
                final normalized = _normalizeBarcode(value);
                if (normalized.isNotEmpty && _isValidBarcode(normalized)) {
                  _onBarcodeFound(normalized);
                } else if (value.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid barcode format'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final normalized = _normalizeBarcode(_textController.text);
                  if (normalized.isNotEmpty && _isValidBarcode(normalized)) {
                    _onBarcodeFound(normalized);
                  } else if (_textController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid barcode format'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Position barcode within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Scanning will happen automatically',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (_scannedCodes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Scanned ${_scannedCodes.length} barcode${_scannedCodes.length == 1 ? '' : 's'}. Tap refresh (↻) to clear history.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    try {
      final barcode = capture.barcodes.firstOrNull;
      if (barcode?.rawValue != null && barcode!.rawValue!.isNotEmpty) {
        final rawValue = barcode.rawValue!;
        debugPrint('Raw barcode detected: "$rawValue" (length: ${rawValue.length})');
        
        final normalizedBarcode = _normalizeBarcode(rawValue);
        debugPrint('Normalized barcode: "$normalizedBarcode" (length: ${normalizedBarcode.length})');
        
        if (normalizedBarcode.isNotEmpty && _isValidBarcode(normalizedBarcode)) {
          debugPrint('Valid barcode accepted: $normalizedBarcode');
          _onBarcodeFound(normalizedBarcode);
        } else {
          debugPrint('Invalid barcode rejected: $normalizedBarcode');
        }
      }
    } catch (e) {
      debugPrint('Barcode detection error: $e');
    }
  }
  
  String _normalizeBarcode(String barcode) {
    try {
      // Remove any whitespace and ensure it's not empty
      final normalized = barcode.trim();
      
      // Basic validation - ensure it's not too short
      if (normalized.length < 3) return '';
      
      // For most barcodes, keep alphanumeric characters and common barcode characters
      final cleaned = normalized.replaceAll(RegExp(r'[^a-zA-Z0-9\-_.]'), '');
      
      return cleaned;
    } catch (e) {
      debugPrint('Barcode normalization error: $e');
      return '';
    }
  }
  
  bool _isValidBarcode(String barcode) {
    // Check if barcode meets basic criteria
    if (barcode.length < 3 || barcode.length > 50) return false;
    
    // Ensure it's not just repeated characters (common scanning error)
    if (RegExp(r'^(.)\1+$').hasMatch(barcode)) return false;
    
    // Ensure it has some alphanumeric content
    if (!RegExp(r'[a-zA-Z0-9]').hasMatch(barcode)) return false;
    
    return true;
  }

  void _onBarcodeFound(String barcode) {
    if (!_isScanning) return;
    
    final now = DateTime.now();
    
    // Check if this is the same barcode scanned recently (within cooldown period)
    if (_lastScannedCode == barcode && 
        _lastScanTime != null && 
        now.difference(_lastScanTime!) < _scanCooldown) {
      return; // Ignore rapid duplicate scans
    }
    
    // Check if this barcode was already scanned (but allow after some time)
    final lastScanTime = _scannedCodes[barcode];
    if (lastScanTime != null && now.difference(lastScanTime) < const Duration(seconds: 3)) {
      _showAlreadyScannedMessage(barcode);
      return;
    }
    
    // Add to scanned codes map with timestamp
    _scannedCodes[barcode] = now;
    
    setState(() {
      _lastScannedCode = barcode;
      _lastScanTime = now;
    });
    
    // Play beep sound and vibrate
    BarcodeService.playBeepSound();
    
    // Show success feedback but don't close scanner
    _showSuccessFeedback(barcode);
    
    // Process the barcode but keep scanner open
    widget.onBarcodeDetected(barcode);
  }

  void _showSuccessFeedback(String barcode) {
    // Show a brief overlay message instead of a dialog
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Barcode Scanned!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Code: $barcode',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Remove the overlay after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
  
  void _showAlreadyScannedMessage(String barcode) {
    // Show a brief overlay message for already scanned items
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Already Scanned',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Code: $barcode',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Remove the overlay after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
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

