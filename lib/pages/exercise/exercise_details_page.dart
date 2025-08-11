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
      body: Stack(
        children: [
          ModelViewer(src: widget.path, autoPlay: true),
          Positioned(
            top: 0,
            right: 20,
            left: 20,
            child: _TimerComponent(time: "01:30"),
          ),
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

class _TimerComponent extends StatelessWidget {
  const _TimerComponent({super.key, required this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF6A5AE0)], // violet
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Phase de travail",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.pause),
                  label: const Text("Pause"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Réinit..."),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
