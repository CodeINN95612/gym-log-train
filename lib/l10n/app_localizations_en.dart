// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navTrainees => 'Trainees';

  @override
  String get navExercises => 'Exercises';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get clone => 'Clone';

  @override
  String get edit => 'Edit';

  @override
  String get seeAll => 'See All';

  @override
  String get loadingEllipsis => 'Loading…';

  @override
  String get menuExportAll => 'Export All';

  @override
  String get menuImport => 'Import';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuAbout => 'About';

  @override
  String get noTrainees => 'No trainees yet.\nTap + to add one.';

  @override
  String exportFailed(String message) {
    return 'Export failed: $message';
  }

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String couldNotReadFile(String message) {
    return 'Could not read file: $message';
  }

  @override
  String importFailed(String message) {
    return 'Import failed: $message';
  }

  @override
  String get importing => 'Importing…';

  @override
  String importSuccess(int count, String exercises) {
    return 'Imported $count trainee(s)$exercises.';
  }

  @override
  String importCreatedExercises(int count) {
    return ', created $count exercise(s)';
  }

  @override
  String get importPreviewTitle => 'Import Preview';

  @override
  String importPreviewTrainees(int count) {
    return '$count trainee(s) will be imported:';
  }

  @override
  String importPreviewAndMore(int count) {
    return 'and $count more…';
  }

  @override
  String get importPreviewNoExercises => 'No exercises referenced.';

  @override
  String importPreviewNewExercises(int count) {
    return '$count new exercise(s) will be created:';
  }

  @override
  String importPreviewExistingExercises(int count) {
    return '$count exercise(s) already exist and will be reused:';
  }

  @override
  String get importPreviewWarning => 'This cannot be undone.';

  @override
  String get importButton => 'Import';

  @override
  String get tooltipExportTrainee => 'Export trainee';

  @override
  String get tooltipImportTrainee => 'Import trainee';

  @override
  String get tooltipDeleteTrainee => 'Delete trainee';

  @override
  String get deleteTraineeTitle => 'Delete Trainee';

  @override
  String deleteTraineeContent(String name) {
    return 'Delete \"$name\" and all their sessions and plan data? This cannot be undone.';
  }

  @override
  String get startSession => 'Start Session';

  @override
  String get progress => 'Progress';

  @override
  String get weeklyPlan => 'Weekly Plan';

  @override
  String get recentSessions => 'Recent Sessions';

  @override
  String get noSessionsYet => 'No sessions yet.';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get active => 'Active';

  @override
  String get rest => 'Rest';

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String get newTrainee => 'New Trainee';

  @override
  String get fieldName => 'Name *';

  @override
  String get fieldNameRequired => 'Name is required';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get appBarExercises => 'Exercises';

  @override
  String get searchExercises => 'Search exercises…';

  @override
  String get filterAll => 'All';

  @override
  String get noExercisesFound => 'No exercises found.\nTap + to add one.';

  @override
  String get newExercise => 'New Exercise';

  @override
  String get fieldMovementPattern => 'Movement pattern';

  @override
  String get hintMovementPattern => 'e.g. Push, Pull, Hinge…';

  @override
  String get fieldMuscleFocus => 'Muscle focus';

  @override
  String get hintMuscleFocus => 'e.g. Chest, Quads, Hamstrings…';

  @override
  String duplicateExercise(String name) {
    return 'An exercise named \"$name\" already exists.';
  }

  @override
  String get newExerciseButton => 'New';

  @override
  String get noExercisesInPicker => 'No exercises found';

  @override
  String newSessionTitle(String weekday) {
    return 'New Session — $weekday';
  }

  @override
  String get todaysPlan => 'Today\'s Plan';

  @override
  String get useTodaysPlan => 'Use Today\'s Plan';

  @override
  String get adHocSession => 'Ad-hoc Session';

  @override
  String get adHocDescription =>
      'Start with an empty session and add exercises as you go.';

  @override
  String get startBlankSession => 'Start Blank Session';

  @override
  String sessionTitle(String date) {
    return 'Session $date';
  }

  @override
  String get sessionTitleGeneric => 'Session';

  @override
  String get sessionInProgress => '● In Progress';

  @override
  String get sessionCompleted => '✓ Completed';

  @override
  String get tooltipDeleteSession => 'Delete session';

  @override
  String get deleteSessionTitle => 'Delete Session';

  @override
  String get deleteSessionContent =>
      'Delete this session and all its logged sets? This cannot be undone.';

  @override
  String get noExercisesInSession =>
      'No exercises added yet.\nTap \"Add Exercise\" to start.';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get endSession => 'End Session';

  @override
  String get endSessionContent => 'Mark this session as completed?';

  @override
  String sessionHistoryTitle(String name) {
    return '$name\'s Sessions';
  }

  @override
  String get noSessionsRecorded => 'No sessions recorded yet.';

  @override
  String progressTitle(String name) {
    return '$name\'s Progress';
  }

  @override
  String get noSessionData => 'No session data yet.';

  @override
  String get statSessions => 'Sessions';

  @override
  String get statExercises => 'Exercises';

  @override
  String get statSince => 'Since';

  @override
  String get personalRecords => 'Personal Records';

  @override
  String get exerciseProgressTitle => 'Exercise Progress';

  @override
  String get metricWeight => 'Weight';

  @override
  String get metricReps => 'Reps';

  @override
  String get metricEstimated1rm => 'Est. 1RM';

  @override
  String get metricDuration => 'Duration';

  @override
  String get noDataForMetric => 'No data for this metric.';

  @override
  String planTitle(String name) {
    return '$name\'s Plan';
  }

  @override
  String get tooltipClonePlan => 'Clone from another trainee';

  @override
  String get planInstruction =>
      'Tap an inactive day to enable it. Tap an active day to expand/collapse.';

  @override
  String get removeDay => 'Remove Day';

  @override
  String removeDayContent(String day) {
    return 'Remove $day from the plan?';
  }

  @override
  String get clonePlanTitle => 'Clone plan from…';

  @override
  String clonePlanSubtitle(String name) {
    return 'Replaces $name\'s current plan.';
  }

  @override
  String get noPlanConfigured => 'No plan configured';

  @override
  String get noOtherTrainees => 'No other trainees found.';

  @override
  String get clonePlanDialogTitle => 'Clone plan?';

  @override
  String clonePlanDialogContent(String target, String source) {
    return 'This will replace $target\'s entire plan with $source\'s plan.';
  }

  @override
  String get appBarAbout => 'About';

  @override
  String get aboutDescription =>
      'A simple tool for personal trainers\nto track their trainees\' progress.';

  @override
  String get starOnGithub => 'Star on GitHub';

  @override
  String get website => 'Website';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get appBarSettings => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get langEnglish => 'English';

  @override
  String get langSpanish => 'Español';
}
