import 'dart:io';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  runApp(const MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Media App',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: CameraHomePage(cameras: cameras),
    );
  }
}

class CameraHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraHomePage({super.key, required this.cameras});

  @override
  State<CameraHomePage> createState() => _CameraHomePageState();
}

class _CameraHomePageState extends State<CameraHomePage> {
  late CameraController _controller;
  bool _isInitialized = false;
  bool _isRecording = false;

  XFile? _selectedImage;
  XFile? _selectedVideo;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.cameras.first, ResolutionPreset.high);

    await _controller.initialize();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _takePhoto() async {
    if (!_controller.value.isInitialized) return;

    final photo = await _controller.takePicture();

    setState(() {
      _selectedImage = photo;
      _selectedVideo = null;
    });
  }

  Future<void> _recordVideo() async {
    if (_isRecording) {
      final video = await _controller.stopVideoRecording();

      setState(() {
        _selectedVideo = video;
        _selectedImage = null;
        _isRecording = false;
      });
    } else {
      await _controller.startVideoRecording();

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _selectedVideo = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();

    final video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _selectedVideo = video;
        _selectedImage = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Camera App')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                ),

                FilledButton.icon(
                  onPressed: _recordVideo,
                  icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
                  label: Text(_isRecording ? 'Stop Recording' : 'Record Video'),
                ),

                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Gallery Image'),
                ),

                OutlinedButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.video_library),
                  label: const Text('Gallery Video'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_selectedImage != null)
              Column(
                children: [
                  const Text(
                    'Selected Image',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Image.file(File(_selectedImage!.path), height: 300),
                ],
              ),

            if (_selectedVideo != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.video_file, size: 80),
                    const SizedBox(height: 10),
                    Text(_selectedVideo!.name, textAlign: TextAlign.center),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
