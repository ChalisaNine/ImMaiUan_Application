import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'Camera_log.dart';
import 'providers/auth_provider.dart';

class AiResultScreen extends StatefulWidget {
  final File imageFile;

  const AiResultScreen({super.key, required this.imageFile});

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  bool _isAnalyzing = true;
  String _errorMessage = "";
  List<dynamic> _detections = [];
  String? _annotatedImageBase64;
  double? _originalGlobalDepth;
  double? _currentGlobalDepth;
  
  double get _depthRatio {
    if (_originalGlobalDepth == null || _originalGlobalDepth == 0) return 1.0;
    return (_currentGlobalDepth ?? 1.0) / _originalGlobalDepth!;
  }

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).authService;
      final response = await authService.analyzeImage(widget.imageFile);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _detections = response.data['detections'] ?? [];
            _originalGlobalDepth = (response.data['global_center_depth_m'] ?? 0.5).toDouble();
            _currentGlobalDepth = _originalGlobalDepth;
            _annotatedImageBase64 = response.data['annotated_image_base64'];
            _isAnalyzing = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                "Failed to analyze image. (Code: ${response.statusCode})";
            _isAnalyzing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Connection Error: $e";
          _isAnalyzing = false;
        });
      }
    }
  }

  void _proceedToLog() {
    final adjustedDetections = _detections.map((item) {
      final updated = Map<String, dynamic>.from(item);
      double origDepth = double.tryParse(updated['center_depth_m']?.toString() ?? '0') ?? 0;
      double origMass = double.tryParse(updated['estimated_portion_g']?.toString() ?? '0') ?? 0;
      
      updated['center_depth_m'] = double.parse((origDepth * _depthRatio).toStringAsFixed(2));
      updated['estimated_portion_g'] = double.parse((origMass * _depthRatio * _depthRatio).toStringAsFixed(2));
      
      return updated;
    }).toList();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CameraLogScreen(detections: adjustedDetections),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const peachDeep = Color(0xFFFFA94D);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Analysis Result",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(peachDeep),
    );
  }

  Widget _buildBody(Color peachDeep) {
    if (_isAnalyzing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: peachDeep),
            const SizedBox(height: 20),
            const Text(
              "Analyzing image...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Detecting food, calculating depth and portions.",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Warning",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: peachDeep,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    // Success state rendering
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                _annotatedImageBase64 != null &&
                    _annotatedImageBase64!.isNotEmpty
                ? Image.memory(
                    base64Decode(_annotatedImageBase64!),
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    widget.imageFile,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 24),

          // Header
          const Text(
            "Detected Features",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Slider for Depth
          if (_currentGlobalDepth != null && _detections.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Camera Distance (Depth)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${_currentGlobalDepth!.toStringAsFixed(2)} m",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: peachDeep),
                    ),
                  ],
                ),
                Slider(
                  value: _currentGlobalDepth!,
                  min: 0.1,
                  max: 2.0,
                  divisions: 190,
                  activeColor: peachDeep,
                  onChanged: (val) {
                    setState(() {
                      _currentGlobalDepth = val;
                    });
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Adjust this slider if the estimated food weight seems off. Modifying the depth mathematically recalibrates the estimated mass.",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),

          if (_detections.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                "No segmentation masks detected in this image.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),

          // Render dynamic detection cards
          for (var item in _detections) _buildItemDetection(item),

          const SizedBox(height: 32),

          // Proceed Button
          ElevatedButton(
            onPressed: _proceedToLog,
            style: ElevatedButton.styleFrom(
              backgroundColor: peachDeep,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Text(
              "Proceed to Meal Log",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // Retake Button
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Retake Photo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetection(Map<String, dynamic> item) {
    String className = item['class']?.toString() ?? 'Unknown';
    String focalLen = item['focal_length_px']?.toString() ?? 'N/A';
    String pct = item['mask_region_pct']?.toString() ?? 'N/A';

    double origDepth = double.tryParse(item['center_depth_m']?.toString() ?? '0') ?? 0;
    double origMass = double.tryParse(item['estimated_portion_g']?.toString() ?? '0') ?? 0;

    double adjDepth = origDepth * _depthRatio;
    double adjMass = origMass * _depthRatio * _depthRatio;

    String depth = adjDepth.toStringAsFixed(2);
    String mass = adjMass.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header for class
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: const Color(0x80FDE9D9),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.orange,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    className.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildResultRow(
                    Icons.straighten_rounded,
                    "Center Depth",
                    "$depth m",
                  ),
                  const Divider(color: Color(0xFFF0F0F0), height: 16),
                  _buildResultRow(
                    Icons.camera_rounded,
                    "Focal Length",
                    "$focalLen px",
                  ),
                  const Divider(color: Color(0xFFF0F0F0), height: 16),
                  _buildResultRow(
                    Icons.pie_chart_rounded,
                    "Mask Region",
                    "$pct%",
                  ),
                  const Divider(color: Color(0xFFF0F0F0), height: 16),
                  _buildResultRow(
                    Icons.scale_rounded,
                    "Estimated Portion",
                    "$mass g",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange.shade300, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
