import 'package:fitness_coach/pages/pages.dart';
import 'package:flutter/material.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = [
      {
        'icon': Icons.fitness_center,
        'iconColor': Colors.deepPurple,
        'title': 'Entraînement de musculation complet',
        'date': 'Aujourd\'hui',
        'duration': '45 minutes',
        'tags': ['Force', 'Complété'],
        'tagColors': [Colors.purple.shade200, Colors.teal.shade200],
      },
      {
        'icon': Icons.directions_run,
        'iconColor': Colors.orange,
        'title': 'Course cardio du matin',
        'date': 'Hier',
        'duration': '30 minutes',
        'tags': ['Cardio', 'Complété'],
        'tagColors': [Colors.orange.shade100, Colors.teal.shade200],
      },
      {
        'icon': Icons.self_improvement,
        'iconColor': Colors.teal,
        'title': 'Flux de yoga du soir',
        'date': 'Dec 15',
        'duration': '60 minutes',
        'tags': ['Yoga', 'Complété'],
        'tagColors': [Colors.teal.shade100, Colors.teal.shade200],
      },
      {
        'icon': Icons.sports,
        'iconColor': Colors.redAccent,
        'title': 'Entraînement en circuit HIIT',
        'date': 'Dec 14',
        'duration': '25 minutes',
        'tags': ['HIIT', 'Sauté'],
        'tagColors': [Colors.red.shade100, Colors.orange.shade100],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mes séances',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche une séance...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // List of sessions
              Expanded(
                child: ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final s = sessions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SessionDetailsPage(
                                name: s['title'] as String,
                              ),
                            ),
                          );
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: s['iconColor'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            s['icon'] as IconData,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          s['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${s['date']} • ${s['duration']}'),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: List.generate(
                                (s['tags'] as List).length,
                                (i) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (s['tagColors'] as List)[i] as Color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    (s['tags'] as List)[i] as String,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
