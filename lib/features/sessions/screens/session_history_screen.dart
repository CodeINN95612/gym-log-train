import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/trainee.dart';
import '../providers/session_provider.dart';
import 'session_detail_screen.dart';

class SessionHistoryScreen extends StatelessWidget {
  final Trainee trainee;

  const SessionHistoryScreen({super.key, required this.trainee});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('${trainee.name}\'s Sessions')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.sessions.isEmpty
              ? const Center(child: Text('No sessions recorded yet.'))
              : ListView.separated(
                  itemCount: provider.sessions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final s = provider.sessions[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: s.isInProgress
                            ? Colors.orange
                            : Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                        child: Icon(
                          s.isInProgress
                              ? Icons.play_arrow
                              : Icons.check,
                          color: s.isInProgress
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                        ),
                      ),
                      title: Text(s.date),
                      subtitle: Text(s.isInProgress
                          ? 'In Progress'
                          : 'Completed'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: context.read<SessionProvider>(),
                            child: SessionDetailScreen(
                              sessionId: s.id!,
                              trainee: trainee,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
