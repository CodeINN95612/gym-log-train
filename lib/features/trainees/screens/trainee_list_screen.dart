import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trainee_provider.dart';
import '../../about/screens/about_screen.dart';
import 'add_trainee_screen.dart';
import 'trainee_overview_screen.dart';

class TraineeListScreen extends StatefulWidget {
  const TraineeListScreen({super.key});

  @override
  State<TraineeListScreen> createState() => _TraineeListScreenState();
}

class _TraineeListScreenState extends State<TraineeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TraineeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TraineeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainees'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'about') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTraineeScreen()),
          );
        },
        child: const Icon(Icons.person_add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.trainees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      const Text(
                        'No trainees yet.\nTap + to add one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: provider.trainees.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final trainee = provider.trainees[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          trainee.name.isNotEmpty
                              ? trainee.name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(trainee.name),
                      subtitle: trainee.notes?.isNotEmpty == true
                          ? Text(
                              trainee.notes!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TraineeOverviewScreen(trainee: trainee),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
