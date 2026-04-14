// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navTrainees => 'Trainees';

  @override
  String get navExercises => 'Ejercicios';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get clone => 'Clonar';

  @override
  String get edit => 'Editar';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get loadingEllipsis => 'Cargando…';

  @override
  String get menuExportAll => 'Exportar todo';

  @override
  String get menuImport => 'Importar';

  @override
  String get menuSettings => 'Configuración';

  @override
  String get menuAbout => 'Acerca de';

  @override
  String get noTrainees => 'Sin trainees aún.\nToca + para agregar uno.';

  @override
  String exportFailed(String message) {
    return 'Error al exportar: $message';
  }

  @override
  String unexpectedError(String error) {
    return 'Error inesperado: $error';
  }

  @override
  String couldNotReadFile(String message) {
    return 'No se pudo leer el archivo: $message';
  }

  @override
  String importFailed(String message) {
    return 'Error al importar: $message';
  }

  @override
  String get importing => 'Importando…';

  @override
  String importSuccess(int count, String exercises) {
    return 'Se importaron $count trainee(s)$exercises.';
  }

  @override
  String importCreatedExercises(int count) {
    return ', se crearon $count ejercicio(s)';
  }

  @override
  String get importPreviewTitle => 'Vista previa de importación';

  @override
  String importPreviewTrainees(int count) {
    return 'Se importarán $count trainee(s):';
  }

  @override
  String importPreviewAndMore(int count) {
    return 'y $count más…';
  }

  @override
  String get importPreviewNoExercises => 'No hay ejercicios referenciados.';

  @override
  String importPreviewNewExercises(int count) {
    return 'Se crearán $count ejercicio(s) nuevo(s):';
  }

  @override
  String importPreviewExistingExercises(int count) {
    return '$count ejercicio(s) ya existen y se reutilizarán:';
  }

  @override
  String get importPreviewWarning => 'Esta acción no se puede deshacer.';

  @override
  String get importButton => 'Importar';

  @override
  String get tooltipExportTrainee => 'Exportar trainee';

  @override
  String get tooltipImportTrainee => 'Importar trainee';

  @override
  String get tooltipDeleteTrainee => 'Eliminar trainee';

  @override
  String get deleteTraineeTitle => 'Eliminar Trainee';

  @override
  String deleteTraineeContent(String name) {
    return '¿Eliminar \"$name\" y todas sus sesiones y datos del plan? Esta acción no se puede deshacer.';
  }

  @override
  String get startSession => 'Iniciar Sesión';

  @override
  String get progress => 'Progreso';

  @override
  String get weeklyPlan => 'Plan Semanal';

  @override
  String get recentSessions => 'Sesiones Recientes';

  @override
  String get noSessionsYet => 'Sin sesiones aún.';

  @override
  String get inProgress => 'En Progreso';

  @override
  String get completed => 'Completado';

  @override
  String get active => 'Activo';

  @override
  String get rest => 'Descanso';

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios',
      one: '1 ejercicio',
    );
    return '$_temp0';
  }

  @override
  String get newTrainee => 'Nuevo Trainee';

  @override
  String get fieldName => 'Nombre *';

  @override
  String get fieldNameRequired => 'El nombre es requerido';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get appBarExercises => 'Ejercicios';

  @override
  String get searchExercises => 'Buscar ejercicios…';

  @override
  String get filterAll => 'Todos';

  @override
  String get noExercisesFound =>
      'No se encontraron ejercicios.\nToca + para agregar uno.';

  @override
  String get newExercise => 'Nuevo Ejercicio';

  @override
  String get fieldMovementPattern => 'Patrón de movimiento';

  @override
  String get hintMovementPattern => 'ej. Push, Pull, Hinge…';

  @override
  String get fieldMuscleFocus => 'Músculo objetivo';

  @override
  String get hintMuscleFocus => 'ej. Chest, Quads, Hamstrings…';

  @override
  String duplicateExercise(String name) {
    return 'Ya existe un ejercicio llamado \"$name\".';
  }

  @override
  String get newExerciseButton => 'Nuevo';

  @override
  String get noExercisesInPicker => 'No se encontraron ejercicios';

  @override
  String newSessionTitle(String weekday) {
    return 'Nueva Sesión — $weekday';
  }

  @override
  String get todaysPlan => 'Plan de Hoy';

  @override
  String get useTodaysPlan => 'Usar Plan de Hoy';

  @override
  String get adHocSession => 'Sesión Libre';

  @override
  String get adHocDescription =>
      'Empieza con una sesión vacía y agrega ejercicios sobre la marcha.';

  @override
  String get startBlankSession => 'Iniciar Sesión en Blanco';

  @override
  String sessionTitle(String date) {
    return 'Sesión $date';
  }

  @override
  String get sessionTitleGeneric => 'Sesión';

  @override
  String get sessionInProgress => '● En Progreso';

  @override
  String get sessionCompleted => '✓ Completado';

  @override
  String get tooltipDeleteSession => 'Eliminar sesión';

  @override
  String get deleteSessionTitle => 'Eliminar Sesión';

  @override
  String get deleteSessionContent =>
      '¿Eliminar esta sesión y todas sus series registradas? Esta acción no se puede deshacer.';

  @override
  String get noExercisesInSession =>
      'Aún no hay ejercicios.\nToca \"Agregar Ejercicio\" para comenzar.';

  @override
  String get addExercise => 'Agregar Ejercicio';

  @override
  String get endSession => 'Terminar Sesión';

  @override
  String get endSessionContent => '¿Marcar esta sesión como completada?';

  @override
  String sessionHistoryTitle(String name) {
    return 'Sesiones de $name';
  }

  @override
  String get noSessionsRecorded => 'No hay sesiones registradas aún.';

  @override
  String progressTitle(String name) {
    return 'Progreso de $name';
  }

  @override
  String get noSessionData => 'Sin datos de sesiones aún.';

  @override
  String get statSessions => 'Sesiones';

  @override
  String get statExercises => 'Ejercicios';

  @override
  String get statSince => 'Desde';

  @override
  String get personalRecords => 'Récords Personales';

  @override
  String get exerciseProgressTitle => 'Progreso por Ejercicio';

  @override
  String get metricWeight => 'Peso';

  @override
  String get metricReps => 'Reps';

  @override
  String get metricEstimated1rm => '1RM Est.';

  @override
  String get metricDuration => 'Duración';

  @override
  String get noDataForMetric => 'Sin datos para esta métrica.';

  @override
  String planTitle(String name) {
    return 'Plan de $name';
  }

  @override
  String get tooltipClonePlan => 'Clonar de otro trainee';

  @override
  String get planInstruction =>
      'Toca un día inactivo para activarlo. Toca un día activo para expandir/colapsar.';

  @override
  String get removeDay => 'Quitar Día';

  @override
  String removeDayContent(String day) {
    return '¿Quitar $day del plan?';
  }

  @override
  String get clonePlanTitle => 'Clonar plan de…';

  @override
  String clonePlanSubtitle(String name) {
    return 'Reemplaza el plan actual de $name.';
  }

  @override
  String get noPlanConfigured => 'Sin plan configurado';

  @override
  String get noOtherTrainees => 'No se encontraron otros trainees.';

  @override
  String get clonePlanDialogTitle => '¿Clonar plan?';

  @override
  String clonePlanDialogContent(String target, String source) {
    return 'Esto reemplazará el plan completo de $target con el de $source.';
  }

  @override
  String get appBarAbout => 'Acerca de';

  @override
  String get aboutDescription =>
      'Una herramienta simple para entrenadores personales\npara seguir el progreso de sus trainees.';

  @override
  String get starOnGithub => 'Destacar en GitHub';

  @override
  String get website => 'Sitio Web';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get donate => 'Apoyar en Ko-fi';

  @override
  String get appBarSettings => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get langEnglish => 'English';

  @override
  String get langSpanish => 'Español';
}
