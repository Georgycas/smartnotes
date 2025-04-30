import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CameraCaptureWidget extends StatefulWidget {
  final Function(String imagePath) onImageCaptured;
  final VoidCallback? onCancel;

  const CameraCaptureWidget({
    super.key,
    required this.onImageCaptured,
    this.onCancel,
  });

  @override
  State<CameraCaptureWidget> createState() => _CameraCaptureWidgetState();
}

class _CameraCaptureWidgetState extends State<CameraCaptureWidget> {
  CameraController? _controller;
  XFile? _capturedImage;
  bool _isPreviewing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(backCamera, ResolutionPreset.medium);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final image = await _controller!.takePicture();
    setState(() {
      _capturedImage = image;
      _isPreviewing = true;
    });
  }

  Future<void> _saveImage() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String uuid = const Uuid().v4();
    final String newPath = '${dir.path}/$uuid.jpg';
    final savedFile = await File(_capturedImage!.path).copy(newPath);
    widget.onImageCaptured(savedFile.path);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (!_isPreviewing)
            CameraPreview(_controller!)
          else
            Image.file(File(_capturedImage!.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: widget.onCancel ?? () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_isPreviewing)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _capturedImage = null;
                        _isPreviewing = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  )
                else
                  FloatingActionButton(
                    onPressed: _takePicture,
                    child: const Icon(Icons.camera_alt),
                  ),
                if (_isPreviewing)
                  ElevatedButton.icon(
                    onPressed: _saveImage,
                    icon: const Icon(Icons.check),
                    label: const Text("Save"),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
