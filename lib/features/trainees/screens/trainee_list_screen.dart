import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/trainee_provider.dart';
import '../../../core/services/export_import_service.dart';
import '../../../shared/widgets/import_preview_dialog.dart';
import '../../about/screens/about_screen.dart';
import '../../settings/screens/settings_screen.dart';
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

  Future<void> _handleExportAll() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ExportImportService().exportAllTrainees();
    } on ExportException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.exportFailed(e.message)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.unexpectedError(e.toString())),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  Future<void> _handleImport() async {
    final l10n = AppLocalizations.of(context)!;
    ImportPreview? preview;
    try {
      preview = await ExportImportService().pickAndPreviewImport();
    } on ImportException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.couldNotReadFile(e.message)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.unexpectedError(e.toString())),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }

    if (preview == null || !mounted) return;

    final confirmed = await showImportPreviewDialog(context, preview);
    if (!confirmed || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Text(l10n.importing),
        ]),
      ),
    );

    ImportResult result;
    try {
      result = await ExportImportService().executeImport(preview);
    } on ImportException catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.importFailed(e.message)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.unexpectedError(e.toString())),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }

    if (mounted) Navigator.pop(context);
    if (mounted) context.read<TraineeProvider>().load();

    if (mounted) {
      final exMsg = result.exercisesCreated > 0
          ? l10n.importCreatedExercises(result.exercisesCreated)
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importSuccess(result.traineesImported, exMsg))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TraineeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTrainees),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'export_all':
                  await _handleExportAll();
                case 'import':
                  await _handleImport();
                case 'settings':
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  }
                case 'about':
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'export_all',
                child: ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: Text(l10n.menuExportAll),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.menuImport),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(l10n.menuSettings),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(value: 'about', child: Text(l10n.menuAbout)),
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
                      Text(
                        l10n.noTrainees,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
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
