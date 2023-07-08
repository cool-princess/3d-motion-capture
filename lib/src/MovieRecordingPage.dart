import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class MovieRecordingPage extends StatefulWidget {
  const MovieRecordingPage({Key? key}) : super(key: key);

  @override
  _MovieRecordingPageState createState() => _MovieRecordingPageState();
}

class _MovieRecordingPageState extends State<MovieRecordingPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller
    _controller = CameraController(
      // Get the first available camera
      CameraDescription(
        name: 'camera',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0,
      ),
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();

    // Initialize the video player controller
    _videoController = VideoPlayerController.networkUrl(Uri.parse(''));
    _initializeVideoPlayerFuture = _videoController.initialize();
  }

  @override
  void dispose() {
    // Dispose of the camera controller and video player controller
    _controller.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    // Start recording
    setState(() {
      _isRecording = true;
    });
    await _controller.startVideoRecording();

    // Play the recording animation
    _videoController.play();
  }

  Future<void> _stopRecording() async {
    if (!_controller.value.isRecordingVideo) {
      return;
    }

    // Stop recording
    setState(() {
      _isRecording = false;
    });
    final path = (await _controller.stopVideoRecording()).path;

    // Stop the recording animation and play the recorded video
    await _videoController.pause();
    await _videoController.setLooping(true);
    await _videoController.setVolume(1.0);
    final uri = Uri.file(path);
    final newVideoController = VideoPlayerController.networkUrl(
      uri,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    await newVideoController.initialize();
    await newVideoController.play();
    setState(() {
      _videoController = newVideoController;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie Recording')),
      body: Column(
        children: [
          // Preview the camera feed
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: CameraPreview(_controller),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),

          // Show the recording status
          Expanded(
            child: Stack(
              children: [
                // Show the recording animation
                FutureBuilder<void>(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),

                // Show the recording button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FloatingActionButton(
                      onPressed: () {
                        if (_isRecording) {
                          _stopRecording();
                        } else {
                          _startRecording();
                        }
                      },
                      child: Icon(_isRecording
                          ? Icons.stop
                          : Icons.fiber_manual_record),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
