import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

// --------- PROVIDER POUR LE TIMER ---------
final timerProvider =
    StateNotifierProvider.autoDispose<TimerNotifier, Duration>(
      (ref) => TimerNotifier(),
    );

class TimerNotifier extends StateNotifier<Duration> {
  TimerNotifier() : super(const Duration(seconds: 90)); // Exemple : 1 min 30
  Timer? _timer;

  void start(VoidCallback onFinish) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.inSeconds > 0) {
        state = Duration(seconds: state.inSeconds - 1);
      } else {
        timer.cancel();
        onFinish();
      }
    });
  }

  void pause() {
    _timer?.cancel();
  }

  void reset(Duration newDuration) {
    _timer?.cancel();
    state = newDuration;
  }
}

// --------- PAGE DETAIL ---------
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Lance le timer
      ref.read(timerProvider.notifier).start(() {
        debugPrint("⏳ Timer terminé, arrêt de l'animation !");
        // Ici, si on veut arrêter l’animation ou passer à autre chose
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeLeft = ref.watch(timerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Stack(
        children: [
          // MODELE 3D
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ModelViewer(src: widget.path, autoPlay: true),
          ),

          // TIMER
          Positioned(
            top: 10,
            right: 20,
            left: 20,
            child: _TimerComponent(
              time: _formatDuration(timeLeft),
              onPause: () => ref.read(timerProvider.notifier).pause(),
              onReset: () => ref
                  .read(timerProvider.notifier)
                  .reset(const Duration(seconds: 90)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

// --------- WIDGET TIMER ---------
class _TimerComponent extends StatelessWidget {
  const _TimerComponent({
    required this.time,
    required this.onPause,
    required this.onReset,
  });

  final String time;
  final VoidCallback onPause;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF6A5AE0)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            time,
            style: const TextStyle(
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
                  onPressed: onPause,
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
                  onPressed: onReset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
