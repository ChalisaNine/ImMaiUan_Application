import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'camera_log.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isBarcodeLoading = false;
  String? _lastDetectedBarcode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(String barcode) async {
    if (_isBarcodeLoading || barcode.isEmpty) return;
    setState(() => _isBarcodeLoading = true);

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
      );
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final product = response.data['product'];
        final nutrients = product['nutriments'] ?? {};

        double portionQuantity = 100.0;
        String portionDescription = "100g";

        print("serving_quantity: ${product['serving_quantity']}");
        print("serving_size: ${product['serving_size']}");

        if (product['serving_quantity'] != null) {
          portionQuantity =
              double.tryParse(product['serving_quantity'].toString()) ?? 100.0;
        }
        if (product['serving_size'] != null &&
            product['serving_size'].toString().isNotEmpty) {
          portionDescription = product['serving_size'].toString();
        }

        final Map<String, dynamic> customData = {
          "name":
              product['product_name'] ??
              product['product_name_en'] ??
              "Unknown Food",
          "energy-kcal_100g": (nutrients['energy-kcal_100g'] ?? 0.0),
          "proteins_100g": (nutrients['proteins_100g'] ?? 0.0),
          "fat_100g": (nutrients['fat_100g'] ?? 0.0),
          "carbohydrates_100g": (nutrients['carbohydrates_100g'] ?? 0.0),
          "sugars_100g": (nutrients['sugars_100g'] ?? 0.0),
          "sodium_100g": (nutrients['sodium_100g'] ?? 0.0),
          "portion_quantity": portionQuantity,
          "portion_description": portionDescription,
          "portion_quantity_unit": product['serving_quantity_unit'],
        };

        print("customData: $customData");

        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final customFoodRes = await authProvider.authService.addCustomFood(
            customData,
          );

          if (customFoodRes.statusCode == 200 ||
              customFoodRes.statusCode == 201) {
            final foodId = customFoodRes.data['food_id'];
            if (mounted) {
              // We use pushReplacement to pop the scanner off the stack completely
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CameraLogScreen(
                    foodId: foodId,
                    foodName: customData["name"],
                  ),
                ),
              );
              return;
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Food not found in OpenFoodFacts database.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Barcode scan error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isBarcodeLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isBarcodeLoading = true);
      try {
        final BarcodeCapture? capture = await _controller.analyzeImage(
          image.path,
        );
        if (capture != null && capture.barcodes.isNotEmpty) {
          final code = capture.barcodes.first.rawValue;
          if (code != null) {
            await _processBarcode(code);
            return;
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No barcode found in the image')),
          );
        }
      } catch (e) {
        if (mounted) {
          _showManualEntryDialog(
            title: "Scanner Error",
            message:
                "Unable to analyze the image on this device. Please enter the barcode manually.",
          );
        }
      } finally {
        if (mounted) setState(() => _isBarcodeLoading = false);
      }
    }
  }

  void _showManualEntryDialog({String? title, String? message}) {
    final TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title ?? "Enter Barcode"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message != null) ...[
                Text(message, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: "e.g. 8850999220000",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () {
                final code = textController.text.trim();
                Navigator.pop(context);
                if (code.isNotEmpty) {
                  _processBarcode(code);
                }
              },
              child: const Text("LOOKUP"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const peachDeep = Color(0xFFFFA94D);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                // Keep the most recent valid barcode
                _lastDetectedBarcode = barcodes.first.rawValue;
              }
            },
          ),

          // Target Area Outline
          Center(
            child: Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "Align barcode here",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ),
          ),

          // Gradient Bottom Profile
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
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
            ),
          ),

          // Back Button top left
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Material(
                  color: Colors.black45,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isBarcodeLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: peachDeep),
                ),
              ),
            ),

          // Controls
          if (!_isBarcodeLoading) ...[
            // Upload from Gallery Button
            Positioned(
              left: 30,
              bottom: 40,
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _pickImage,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "UPLOAD",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Manual Entry Button
            Positioned(
              right: 30,
              bottom: 40,
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showManualEntryDialog(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.keyboard_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "MANUAL",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Snap Button
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // Snap button simply processes the last detected code in view
                    if (_lastDetectedBarcode != null) {
                      _processBarcode(_lastDetectedBarcode!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please align a barcode in view first'),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: peachDeep,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
