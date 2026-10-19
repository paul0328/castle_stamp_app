import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraView extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(String path) onPhotoTaken;
  const CameraView({super.key, required this.cameras, required this.onPhotoTaken});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(widget.cameras.first, ResolutionPreset.high);
      _controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 網頁版或無相機設備時提供模擬畫面方便測試
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('相機模擬測試')),
        body: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC92A2A)),
            onPressed: () => widget.onPhotoTaken('mock_path/photo.png'),
            child: const Text('模擬拍照點擊', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFC92A2A), // 朱紅快門鈕
                onPressed: () async {
                  final image = await _controller!.takePicture();
                  widget.onPhotoTaken(image.path);
                },
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
