import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ExerciseDetailsPage extends ConsumerStatefulWidget {
  const ExerciseDetailsPage({
    super.key,
    required this.name,
    required this.path,
  });
  final String name;
  final String path;

  @override
  ConsumerState<ExerciseDetailsPage> createState() =>
      _ExerciseDetailsPageState();
}

class _ExerciseDetailsPageState extends ConsumerState<ExerciseDetailsPage> {
  final Flutter3DController controller = Flutter3DController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.onModelLoaded.value) {
        controller.playAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        children: [
          Expanded(child: ModelViewer(src: widget.path, autoPlay: true)),
          // Expanded(
          //   child: Flutter3DViewer(
          //     controller: controller,
          //     onLoad: (modelAddress) {
          //       print(modelAddress);
          //     },
          //     onProgress: (progressValue) {
          //       print(progressValue);
          //       if (progressValue == 1.0) {
          //         controller.playAnimation();
          //       } else {}
          //     },
          //     src: widget.path, // Path to your FBX model
          //     // You can add various other properties here for animation, camera control, etc.
          //   ),
          // ),
        ],
      ),
    );
  }
}

class SessionNotifier extends StateNotifier<int> {
  SessionNotifier() : super(0);

  void next(int total) {
    if (state < total - 1) {
      state++;
    }
  }

  void reset() => state = 0;
}

final currentExerciseIndexProvider =
    StateNotifierProvider<SessionNotifier, int>((ref) => SessionNotifier());
