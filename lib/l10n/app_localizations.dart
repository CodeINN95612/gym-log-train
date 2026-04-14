import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @navTrainees.
  ///
  /// In en, this message translates to:
  /// **'Trainees'**
  String get navTrainees;

  /// No description provided for @navExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get navExercises;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @clone.
  ///
  /// In en, this message translates to:
  /// **'Clone'**
  String get clone;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @loadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingEllipsis;

  /// No description provided for @menuExportAll.
  ///
  /// In en, this message translates to:
  /// **'Export All'**
  String get menuExportAll;

  /// No description provided for @menuImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get menuImport;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// No description provided for @noTrainees.
  ///
  /// In en, this message translates to:
  /// **'No trainees yet.\nTap + to add one.'**
  String get noTrainees;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {message}'**
  String exportFailed(String message);

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(String error);

  /// No description provided for @couldNotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read file: {message}'**
  String couldNotReadFile(String message);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {message}'**
  String importFailed(String message);

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importing;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} trainee(s){exercises}.'**
  String importSuccess(int count, String exercises);

  /// No description provided for @importCreatedExercises.
  ///
  /// In en, this message translates to:
  /// **', created {count} exercise(s)'**
  String importCreatedExercises(int count);

  /// No description provided for @importPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Preview'**
  String get importPreviewTitle;

  /// No description provided for @importPreviewTrainees.
  ///
  /// In en, this message translates to:
  /// **'{count} trainee(s) will be imported:'**
  String importPreviewTrainees(int count);

  /// No description provided for @importPreviewAndMore.
  ///
  /// In en, this message translates to:
  /// **'and {count} more…'**
  String importPreviewAndMore(int count);

  /// No description provided for @importPreviewNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises referenced.'**
  String get importPreviewNoExercises;

  /// No description provided for @importPreviewNewExercises.
  ///
  /// In en, this message translates to:
  /// **'{count} new exercise(s) will be created:'**
  String importPreviewNewExercises(int count);

  /// No description provided for @importPreviewExistingExercises.
  ///
  /// In en, this message translates to:
  /// **'{count} exercise(s) already exist and will be reused:'**
  String importPreviewExistingExercises(int count);

  /// No description provided for @importPreviewWarning.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get importPreviewWarning;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @tooltipExportTrainee.
  ///
  /// In en, this message translates to:
  /// **'Export trainee'**
  String get tooltipExportTrainee;

  /// No description provided for @tooltipImportTrainee.
  ///
  /// In en, this message translates to:
  /// **'Import trainee'**
  String get tooltipImportTrainee;

  /// No description provided for @tooltipDeleteTrainee.
  ///
  /// In en, this message translates to:
  /// **'Delete trainee'**
  String get tooltipDeleteTrainee;

  /// No description provided for @deleteTraineeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Trainee'**
  String get deleteTraineeTitle;

  /// No description provided for @deleteTraineeContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" and all their sessions and plan data? This cannot be undone.'**
  String deleteTraineeContent(String name);

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get startSession;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @weeklyPlan.
  ///
  /// In en, this message translates to:
  /// **'Weekly Plan'**
  String get weeklyPlan;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent Sessions'**
  String get recentSessions;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet.'**
  String get noSessionsYet;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise} other{{count} exercises}}'**
  String exerciseCount(int count);

  /// No description provided for @newTrainee.
  ///
  /// In en, this message translates to:
  /// **'New Trainee'**
  String get newTrainee;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get fieldName;

  /// No description provided for @fieldNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get fieldNameRequired;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @appBarExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get appBarExercises;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises…'**
  String get searchExercises;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found.\nTap + to add one.'**
  String get noExercisesFound;

  /// No description provided for @newExercise.
  ///
  /// In en, this message translates to:
  /// **'New Exercise'**
  String get newExercise;

  /// No description provided for @fieldMovementPattern.
  ///
  /// In en, this message translates to:
  /// **'Movement pattern'**
  String get fieldMovementPattern;

  /// No description provided for @hintMovementPattern.
  ///
  /// In en, this message translates to:
  /// **'e.g. Push, Pull, Hinge…'**
  String get hintMovementPattern;

  /// No description provided for @fieldMuscleFocus.
  ///
  /// In en, this message translates to:
  /// **'Muscle focus'**
  String get fieldMuscleFocus;

  /// No description provided for @hintMuscleFocus.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chest, Quads, Hamstrings…'**
  String get hintMuscleFocus;

  /// No description provided for @duplicateExercise.
  ///
  /// In en, this message translates to:
  /// **'An exercise named \"{name}\" already exists.'**
  String duplicateExercise(String name);

  /// No description provided for @newExerciseButton.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newExerciseButton;

  /// No description provided for @noExercisesInPicker.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get noExercisesInPicker;

  /// No description provided for @newSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'New Session — {weekday}'**
  String newSessionTitle(String weekday);

  /// No description provided for @todaysPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Plan'**
  String get todaysPlan;

  /// No description provided for @useTodaysPlan.
  ///
  /// In en, this message translates to:
  /// **'Use Today\'s Plan'**
  String get useTodaysPlan;

  /// No description provided for @adHocSession.
  ///
  /// In en, this message translates to:
  /// **'Ad-hoc Session'**
  String get adHocSession;

  /// No description provided for @adHocDescription.
  ///
  /// In en, this message translates to:
  /// **'Start with an empty session and add exercises as you go.'**
  String get adHocDescription;

  /// No description provided for @startBlankSession.
  ///
  /// In en, this message translates to:
  /// **'Start Blank Session'**
  String get startBlankSession;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session {date}'**
  String sessionTitle(String date);

  /// No description provided for @sessionTitleGeneric.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionTitleGeneric;

  /// No description provided for @sessionInProgress.
  ///
  /// In en, this message translates to:
  /// **'● In Progress'**
  String get sessionInProgress;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'✓ Completed'**
  String get sessionCompleted;

  /// No description provided for @tooltipDeleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get tooltipDeleteSession;

  /// No description provided for @deleteSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Session'**
  String get deleteSessionTitle;

  /// No description provided for @deleteSessionContent.
  ///
  /// In en, this message translates to:
  /// **'Delete this session and all its logged sets? This cannot be undone.'**
  String get deleteSessionContent;

  /// No description provided for @noExercisesInSession.
  ///
  /// In en, this message translates to:
  /// **'No exercises added yet.\nTap \"Add Exercise\" to start.'**
  String get noExercisesInSession;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get endSession;

  /// No description provided for @endSessionContent.
  ///
  /// In en, this message translates to:
  /// **'Mark this session as completed?'**
  String get endSessionContent;

  /// No description provided for @sessionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Sessions'**
  String sessionHistoryTitle(String name);

  /// No description provided for @noSessionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No sessions recorded yet.'**
  String get noSessionsRecorded;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Progress'**
  String progressTitle(String name);

  /// No description provided for @noSessionData.
  ///
  /// In en, this message translates to:
  /// **'No session data yet.'**
  String get noSessionData;

  /// No description provided for @statSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get statSessions;

  /// No description provided for @statExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get statExercises;

  /// No description provided for @statSince.
  ///
  /// In en, this message translates to:
  /// **'Since'**
  String get statSince;

  /// No description provided for @personalRecords.
  ///
  /// In en, this message translates to:
  /// **'Personal Records'**
  String get personalRecords;

  /// No description provided for @exerciseProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Progress'**
  String get exerciseProgressTitle;

  /// No description provided for @metricWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get metricWeight;

  /// No description provided for @metricReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get metricReps;

  /// No description provided for @metricEstimated1rm.
  ///
  /// In en, this message translates to:
  /// **'Est. 1RM'**
  String get metricEstimated1rm;

  /// No description provided for @metricDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get metricDuration;

  /// No description provided for @noDataForMetric.
  ///
  /// In en, this message translates to:
  /// **'No data for this metric.'**
  String get noDataForMetric;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Plan'**
  String planTitle(String name);

  /// No description provided for @tooltipClonePlan.
  ///
  /// In en, this message translates to:
  /// **'Clone from another trainee'**
  String get tooltipClonePlan;

  /// No description provided for @planInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap an inactive day to enable it. Tap an active day to expand/collapse.'**
  String get planInstruction;

  /// No description provided for @removeDay.
  ///
  /// In en, this message translates to:
  /// **'Remove Day'**
  String get removeDay;

  /// No description provided for @removeDayContent.
  ///
  /// In en, this message translates to:
  /// **'Remove {day} from the plan?'**
  String removeDayContent(String day);

  /// No description provided for @clonePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Clone plan from…'**
  String get clonePlanTitle;

  /// No description provided for @clonePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replaces {name}\'s current plan.'**
  String clonePlanSubtitle(String name);

  /// No description provided for @noPlanConfigured.
  ///
  /// In en, this message translates to:
  /// **'No plan configured'**
  String get noPlanConfigured;

  /// No description provided for @noOtherTrainees.
  ///
  /// In en, this message translates to:
  /// **'No other trainees found.'**
  String get noOtherTrainees;

  /// No description provided for @clonePlanDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clone plan?'**
  String get clonePlanDialogTitle;

  /// No description provided for @clonePlanDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will replace {target}\'s entire plan with {source}\'s plan.'**
  String clonePlanDialogContent(String target, String source);

  /// No description provided for @appBarAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get appBarAbout;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A simple tool for personal trainers\nto track their trainees\' progress.'**
  String get aboutDescription;

  /// No description provided for @starOnGithub.
  ///
  /// In en, this message translates to:
  /// **'Star on GitHub'**
  String get starOnGithub;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Support on Ko-fi'**
  String get donate;

  /// No description provided for @appBarSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appBarSettings;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get langSpanish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
