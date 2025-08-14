import 'package:fitness_coach/pages/pages.dart';
import 'package:flutter/material.dart';

class SessionDetailsPage extends StatelessWidget {
  const SessionDetailsPage({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(name),
        leading: BackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TIMER BOX
          TimerComponent(time: "01:30"),
          const SizedBox(height: 20),
          // APERÇU
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _SessionInfo(label: "Duration", value: "30 minutes"),
                _SessionInfo(label: "Tours", value: "6 rounds"),
                _SessionInfo(label: "Travail/Repos", value: "45s/15s"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Liste d'exercices",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          _ExerciseTile(
            icon: Icons.fitness_center,
            title: "Squat",
            subtitle: "Mouvement explosif de tout le corps",
            duration: "45 seconds",
            path: 'assets/models/squat_minify.glb',
          ),
          _ExerciseTile(
            icon: Icons.directions_run,
            title: "Situps",
            subtitle: "Exercices de base et cardio",
            duration: "45 seconds",
            path: 'assets/models/situps_minify.glb',
          ),
        ],
      ),
    );
  }
}

class TimerComponent extends StatelessWidget {
  const TimerComponent({super.key, required this.time});
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6A5AE0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: const Icon(Icons.play_arrow),
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
                  onPressed: () {},
                  child: const Icon(Icons.pause),
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
                  onPressed: () {},
                  child: Icon(Icons.refresh),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionInfo extends StatelessWidget {
  final String label;
  final String value;

  const _SessionInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String duration;
  final String path;

  const _ExerciseTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ExerciseDetailsPage(name: title, path: path),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF6A5AE0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(duration, style: const TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.black54),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ExerciseDetailsPage(name: title, path: path),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
