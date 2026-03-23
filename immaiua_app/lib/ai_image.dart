import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
      body: const _CameraBody(),
    );
  }
}

/* ========================================================================= */
/*                                CAMERA BODY                                */
/* ========================================================================= */

class _CameraBody extends StatefulWidget {
  const _CameraBody();

  @override
  State<_CameraBody> createState() => _CameraBodyState();
}

class _CameraBodyState extends State<_CameraBody> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
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

  void _clearImage() {
    setState(() {
      _imageFile = null;
    });
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
      MaterialPageRoute(builder: (_) => AiResultScreen(imageFile: _imageFile!)),
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
              : Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Text(
                      "Tap the camera to start",
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                ),
        ),

        // ---------- Center Target Area (Camera tap area if empty) ----------
        if (_imageFile == null)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _pickImage(ImageSource.camera),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
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
