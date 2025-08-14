import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

// --------- PROVIDER POUR LE TIMER ---------
final timerProvider =
    StateNotifierProvider.autoDispose<TimerNotifier, TimerState>(
      (ref) => TimerNotifier(),
    );

class TimerState {
  final Duration timeLeft;
  final bool isRunning;

  const TimerState({required this.timeLeft, required this.isRunning});

  TimerState copyWith({Duration? timeLeft, bool? isRunning}) {
    return TimerState(
      timeLeft: timeLeft ?? this.timeLeft,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier()
    : super(
        const TimerState(timeLeft: Duration(seconds: 90), isRunning: false),
      );

  Timer? _timer;

  void start(VoidCallback onFinish) {
    _timer?.cancel();
    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft.inSeconds > 0) {
        state = state.copyWith(
          timeLeft: Duration(seconds: state.timeLeft.inSeconds - 1),
        );
      } else {
        timer.cancel();
        state = state.copyWith(isRunning: false);
        onFinish();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void toggle(VoidCallback onFinish) {
    if (state.isRunning) {
      pause();
    } else {
      start(onFinish);
    }
  }

  void reset(Duration newDuration) {
    _timer?.cancel();
    state = TimerState(timeLeft: newDuration, isRunning: false);
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
      ref.read(timerProvider.notifier).start(() {
        debugPrint("⏳ Timer terminé, arrêt de l'animation !");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.name), backgroundColor: Colors.white),
      body: Stack(
        children: [
          // MODELE 3D
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .7,
              width: double.infinity,
              child: ModelViewer(src: widget.path, autoPlay: true),
            ),
          ),

          // TIMER
          Positioned(
            top: 0,
            right: 20,
            left: 20,
            child: _TimerComponent(
              time: _formatDuration(timerState.timeLeft),
              isRunning: timerState.isRunning,
              onToggle: () => ref
                  .read(timerProvider.notifier)
                  .toggle(() => debugPrint("Timer terminé")),
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

class _TimerComponent extends StatelessWidget {
  const _TimerComponent({
    required this.time,
    required this.isRunning,
    required this.onToggle,
    required this.onReset,
  });

  final String time;
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: onToggle,
                  child: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: onReset,
                  child: const Icon(Icons.refresh),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
