import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'barcode_scanner_screen.dart';

import 'nav_bar.dart';
import 'main.dart';
import 'Meal.dart';
import 'Calenda.dart';
import 'profile_screen.dart';
import 'camera_log.dart';
import 'ai_result.dart';

class AiImageScreen extends StatefulWidget {
  const AiImageScreen({super.key});

  @override
  State<AiImageScreen> createState() => _AiImageScreenState();
}

class _AiImageScreenState extends State<AiImageScreen> {
  int _index = 2; // Capture tab
  final GlobalKey<_CameraBodyState> _cameraKey = GlobalKey<_CameraBodyState>();

  void _onTap(int i) {
    setState(() => _index = i);

    switch (i) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainHomeScreen()),
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MealScreen()),
        );
        break;

      case 2: // ⭐ ปุ่มกล้องสีน้ำตาล (กลาง NavBar)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CameraLogScreen()),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendaScreen()),
        );
        break;

      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,
      showBackButton: false,
      onCameraTap: () {
        _cameraKey.currentState?._handleCameraAction();
      },
      body: _CameraBody(key: _cameraKey),
    );
  }
}

/* ========================================================================= */
/*                                CAMERA BODY                                */
/* ========================================================================= */

class _CameraBody extends StatefulWidget {
  const _CameraBody({super.key});

  @override
  State<_CameraBody> createState() => _CameraBodyState();
}

class _CameraBodyState extends State<_CameraBody> with WidgetsBindingObserver {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isClassificationMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  void _openBarcodeScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    // Cannot take a new picture if we already have one
    if (_imageFile != null) return;
    
    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _imageFile = File(image.path);
      });
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  void _handleCameraAction() {
    if (_imageFile == null) {
      _takePicture();
    } else {
      _mockScanToLog();
    }
  }

  void _clearImage() {
    setState(() {
      _imageFile = null;
    });
  }

  Widget _buildSwitchItem({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFFFB300) : const Color(0xFF757575),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? const Color(0xFFFFB300) : const Color(0xFF757575),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mockScanToLog() {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take or select a photo first!')),
      );
      return;
    }
    // Navigate to the AI analysis result screen first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AiResultScreen(
        imageFile: _imageFile!,
        isClassificationMode: _isClassificationMode,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    const peachDeep = Color(0xFFFFA94D);

    return Stack(
      children: [
        // ---------- พรีวิวภาพ ----------
        Positioned.fill(
          child: _imageFile != null
              ? Image.file(_imageFile!, fit: BoxFit.cover)
              : (_isCameraInitialized
                  ? CameraPreview(_cameraController!)
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(color: peachDeep),
                      ),
                    )),
        ),

        // ---------- วงกลมเล็ง ----------
        IgnorePointer(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              height: MediaQuery.of(context).size.width * 0.70,
              child: CustomPaint(painter: _FocusRingPainter()),
            ),
          ),
        ),

        // ---------- Mode Switcher ----------
        Positioned(
          top: MediaQuery.of(context).padding.top > 0 
                  ? MediaQuery.of(context).padding.top + 16 
                  : 54,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSwitchItem(
                    title: "Portion",
                    icon: Icons.star_rounded,
                    isActive: !_isClassificationMode,
                    onTap: () => setState(() => _isClassificationMode = false),
                  ),
                  _buildSwitchItem(
                    title: "Classify",
                    icon: Icons.crop_free_rounded,
                    isActive: _isClassificationMode,
                    onTap: () => setState(() => _isClassificationMode = true),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ---------- Center "SCAN" Action Button ----------
        if (_imageFile != null)
          Center(
            child: ElevatedButton.icon(
              onPressed: _mockScanToLog,
              icon: const Icon(Icons.document_scanner_rounded, size: 28),
              label: const Text(
                "SCAN MEAL",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: peachDeep,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
              ),
            ),
          ),

        // ---------- Gradient ล่าง ----------
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black45, Colors.black87],
                ),
              ),
            ),
          ),
        ),

        // ---------- Upload ----------
        Positioned(
          left: 20,
          bottom: 110,
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "UPLOAD",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // ---------- Refresh/Barcode ----------
        Positioned(
          right: 20,
          bottom: 110,
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _imageFile != null ? _clearImage : _openBarcodeScanner,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: _imageFile != null ? Colors.white24 : peachDeep,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _imageFile != null
                        ? Icons.refresh_rounded
                        : Icons.qr_code_scanner_rounded, // or barcode
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _imageFile != null ? "RETAKE" : "BARCODE",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ========================================================================= */
/*                            CAMERA FOCUS RING                              */
/* ========================================================================= */

class _FocusRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = Colors.white24
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final inner = Paint()
      ..color = Colors.white38
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final r = size.width / 2;

    canvas.drawCircle(Offset(r, r), r, outer);
    canvas.drawCircle(Offset(r, r), r * 0.75, inner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
