class Migrations {
  static const Map<int, List<String>> scripts = {
    1: [
      '''
      CREATE TABLE trainees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        category TEXT,
        created_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE plan_days (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trainee_id INTEGER NOT NULL,
        weekday INTEGER NOT NULL,
        label TEXT,
        FOREIGN KEY (trainee_id) REFERENCES trainees(id) ON DELETE CASCADE
      )
      ''',
      '''
      CREATE TABLE plan_day_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_day_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (plan_day_id) REFERENCES plan_days(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      )
      ''',
      '''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trainee_id INTEGER NOT NULL,
        plan_day_id INTEGER,
        date TEXT NOT NULL,
        notes TEXT,
        started_at INTEGER,
        ended_at INTEGER,
        FOREIGN KEY (trainee_id) REFERENCES trainees(id) ON DELETE CASCADE,
        FOREIGN KEY (plan_day_id) REFERENCES plan_days(id) ON DELETE SET NULL
      )
      ''',
      '''
      CREATE TABLE session_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      )
      ''',
      '''
      CREATE TABLE sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_exercise_id INTEGER NOT NULL,
        set_number INTEGER NOT NULL,
        reps INTEGER,
        weight_kg REAL,
        duration_seconds INTEGER,
        completed INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (session_exercise_id) REFERENCES session_exercises(id) ON DELETE CASCADE
      )
      ''',
    ],
    2: [
      'ALTER TABLE exercises ADD COLUMN muscle_focus TEXT',
    ],
    3: [
      // Seed common exercises. INSERT OR IGNORE skips any that already exist by name.
      '''
      INSERT OR IGNORE INTO exercises (name, category, muscle_focus, created_at) VALUES
        -- Push
        ('Bench Press',            'Push', 'Chest',      0),
        ('Incline Bench Press',    'Push', 'Chest',      0),
        ('Decline Bench Press',    'Push', 'Chest',      0),
        ('Dumbbell Fly',           'Push', 'Chest',      0),
        ('Push-up',                'Push', 'Chest',      0),
        ('Overhead Press',         'Push', 'Shoulders',  0),
        ('Dumbbell Shoulder Press','Push', 'Shoulders',  0),
        ('Lateral Raise',          'Push', 'Shoulders',  0),
        ('Front Raise',            'Push', 'Shoulders',  0),
        ('Dips',                   'Push', 'Triceps',    0),
        ('Tricep Pushdown',        'Push', 'Triceps',    0),
        ('Skull Crusher',          'Push', 'Triceps',    0),
        ('Close-Grip Bench Press', 'Push', 'Triceps',    0),
        -- Pull
        ('Pull-up',                'Pull', 'Upper Back', 0),
        ('Chin-up',                'Pull', 'Biceps',     0),
        ('Lat Pulldown',           'Pull', 'Upper Back', 0),
        ('Seated Cable Row',       'Pull', 'Upper Back', 0),
        ('Barbell Row',            'Pull', 'Upper Back', 0),
        ('Dumbbell Row',           'Pull', 'Upper Back', 0),
        ('T-Bar Row',              'Pull', 'Upper Back', 0),
        ('Face Pull',              'Pull', 'Shoulders',  0),
        ('Bicep Curl',             'Pull', 'Biceps',     0),
        ('Hammer Curl',            'Pull', 'Biceps',     0),
        ('Incline Dumbbell Curl',  'Pull', 'Biceps',     0),
        ('Cable Curl',             'Pull', 'Biceps',     0),
        -- Hinge
        ('Deadlift',               'Hinge', 'Lower Back', 0),
        ('Romanian Deadlift',      'Hinge', 'Hamstrings', 0),
        ('Stiff-Leg Deadlift',     'Hinge', 'Hamstrings', 0),
        ('Hip Thrust',             'Hinge', 'Glutes',     0),
        ('Glute Bridge',           'Hinge', 'Glutes',     0),
        ('Good Morning',           'Hinge', 'Lower Back', 0),
        ('Kettlebell Swing',       'Hinge', 'Glutes',     0),
        ('Leg Curl',               'Hinge', 'Hamstrings', 0),
        -- Squat
        ('Back Squat',             'Squat', 'Quads',  0),
        ('Front Squat',            'Squat', 'Quads',  0),
        ('Goblet Squat',           'Squat', 'Quads',  0),
        ('Leg Press',              'Squat', 'Quads',  0),
        ('Hack Squat',             'Squat', 'Quads',  0),
        ('Leg Extension',          'Squat', 'Quads',  0),
        ('Sumo Squat',             'Squat', 'Glutes', 0),
        -- Lunge
        ('Walking Lunge',          'Lunge', 'Quads',  0),
        ('Reverse Lunge',          'Lunge', 'Glutes', 0),
        ('Bulgarian Split Squat',  'Lunge', 'Glutes', 0),
        ('Step-up',                'Lunge', 'Quads',  0),
        ('Lateral Lunge',          'Lunge', 'Quads',  0),
        -- Core
        ('Plank',                  'Core', 'Abs',      0),
        ('Side Plank',             'Core', 'Obliques', 0),
        ('Crunch',                 'Core', 'Abs',      0),
        ('Bicycle Crunch',         'Core', 'Obliques', 0),
        ('Leg Raise',              'Core', 'Abs',      0),
        ('Ab Wheel Rollout',       'Core', 'Abs',      0),
        ('Cable Crunch',           'Core', 'Abs',      0),
        ('Russian Twist',          'Core', 'Obliques', 0),
        ('Hanging Knee Raise',     'Core', 'Abs',      0),
        -- Cardio
        ('Running',                'Cardio', 'Other', 0),
        ('Cycling',                'Cardio', 'Other', 0),
        ('Rowing Machine',         'Cardio', 'Other', 0),
        ('Jump Rope',              'Cardio', 'Other', 0),
        ('Elliptical',             'Cardio', 'Other', 0),
        ('Stair Climber',          'Cardio', 'Other', 0),
        -- Full Body
        ('Burpee',                 'Full Body', 'Other', 0),
        ('Clean and Press',        'Full Body', 'Other', 0),
        ('Thruster',               'Full Body', 'Quads', 0),
        ('Farmer''s Walk',         'Full Body', 'Other', 0),
        ('Battle Ropes',           'Full Body', 'Other', 0)
      '''
    ],
    5: [
      "ALTER TABLE exercises ADD COLUMN language TEXT NOT NULL DEFAULT 'en'",
      '''
      INSERT OR IGNORE INTO exercises (name, category, muscle_focus, language, created_at) VALUES
        -- Push
        ('Press de Banca',                   'Push', 'Chest',      'es', 0),
        ('Press de Banca Inclinado',          'Push', 'Chest',      'es', 0),
        ('Press de Banca Declinado',          'Push', 'Chest',      'es', 0),
        ('Aperturas con Mancuernas',          'Push', 'Chest',      'es', 0),
        ('Flexiones',                         'Push', 'Chest',      'es', 0),
        ('Press Militar',                     'Push', 'Shoulders',  'es', 0),
        ('Press de Hombro con Mancuerna',     'Push', 'Shoulders',  'es', 0),
        ('Elevación Lateral',                 'Push', 'Shoulders',  'es', 0),
        ('Elevación Frontal',                 'Push', 'Shoulders',  'es', 0),
        ('Fondos en Paralelas',               'Push', 'Triceps',    'es', 0),
        ('Jalón de Tríceps',                  'Push', 'Triceps',    'es', 0),
        ('Rompecráneos',                      'Push', 'Triceps',    'es', 0),
        ('Press de Banca Agarre Cerrado',     'Push', 'Triceps',    'es', 0),
        -- Pull
        ('Dominadas',                         'Pull', 'Upper Back', 'es', 0),
        ('Dominadas Supinas',                 'Pull', 'Biceps',     'es', 0),
        ('Jalón al Pecho',                    'Pull', 'Upper Back', 'es', 0),
        ('Remo en Polea Sentado',             'Pull', 'Upper Back', 'es', 0),
        ('Remo con Barra',                    'Pull', 'Upper Back', 'es', 0),
        ('Remo con Mancuerna',                'Pull', 'Upper Back', 'es', 0),
        ('Remo en T',                         'Pull', 'Upper Back', 'es', 0),
        ('Face Pull',                         'Pull', 'Shoulders',  'es', 0),
        ('Curl de Bíceps con Barra',          'Pull', 'Biceps',     'es', 0),
        ('Curl Martillo',                     'Pull', 'Biceps',     'es', 0),
        ('Curl Inclinado con Mancuerna',      'Pull', 'Biceps',     'es', 0),
        ('Curl en Polea',                     'Pull', 'Biceps',     'es', 0),
        -- Hinge
        ('Peso Muerto',                       'Hinge', 'Lower Back', 'es', 0),
        ('Peso Muerto Rumano',                'Hinge', 'Hamstrings', 'es', 0),
        ('Peso Muerto Piernas Rígidas',       'Hinge', 'Hamstrings', 'es', 0),
        ('Empuje de Cadera',                  'Hinge', 'Glutes',     'es', 0),
        ('Puente de Glúteos',                 'Hinge', 'Glutes',     'es', 0),
        ('Buenos Días',                       'Hinge', 'Lower Back', 'es', 0),
        ('Swing con Kettlebell',              'Hinge', 'Glutes',     'es', 0),
        ('Curl de Pierna',                    'Hinge', 'Hamstrings', 'es', 0),
        -- Squat
        ('Sentadilla Trasera',                'Squat', 'Quads',  'es', 0),
        ('Sentadilla Frontal',                'Squat', 'Quads',  'es', 0),
        ('Sentadilla Goblet',                 'Squat', 'Quads',  'es', 0),
        ('Prensa de Piernas',                 'Squat', 'Quads',  'es', 0),
        ('Hack Squat',                        'Squat', 'Quads',  'es', 0),
        ('Extensión de Piernas',              'Squat', 'Quads',  'es', 0),
        ('Sentadilla Sumo',                   'Squat', 'Glutes', 'es', 0),
        -- Lunge
        ('Estocada Caminando',                'Lunge', 'Quads',  'es', 0),
        ('Estocada Inversa',                  'Lunge', 'Glutes', 'es', 0),
        ('Sentadilla Búlgara',                'Lunge', 'Glutes', 'es', 0),
        ('Step-up',                           'Lunge', 'Quads',  'es', 0),
        ('Estocada Lateral',                  'Lunge', 'Quads',  'es', 0),
        -- Core
        ('Plancha',                           'Core', 'Abs',      'es', 0),
        ('Plancha Lateral',                   'Core', 'Obliques', 'es', 0),
        ('Crunch',                            'Core', 'Abs',      'es', 0),
        ('Crunch de Bicicleta',               'Core', 'Obliques', 'es', 0),
        ('Elevación de Piernas',              'Core', 'Abs',      'es', 0),
        ('Rueda Abdominal',                   'Core', 'Abs',      'es', 0),
        ('Crunch en Polea',                   'Core', 'Abs',      'es', 0),
        ('Giro Ruso',                         'Core', 'Obliques', 'es', 0),
        ('Elevación de Rodillas Colgado',     'Core', 'Abs',      'es', 0),
        -- Cardio
        ('Correr',                            'Cardio', 'Other', 'es', 0),
        ('Ciclismo',                          'Cardio', 'Other', 'es', 0),
        ('Máquina de Remo',                   'Cardio', 'Other', 'es', 0),
        ('Saltar la Cuerda',                  'Cardio', 'Other', 'es', 0),
        ('Elíptica',                          'Cardio', 'Other', 'es', 0),
        ('Escaladora',                        'Cardio', 'Other', 'es', 0),
        -- Full Body
        ('Burpee',                            'Full Body', 'Other', 'es', 0),
        ('Arrancada y Press',                 'Full Body', 'Other', 'es', 0),
        ('Thruster',                          'Full Body', 'Quads', 'es', 0),
        ('Caminata del Granjero',             'Full Body', 'Other', 'es', 0),
        ('Cuerdas de Batalla',                'Full Body', 'Other', 'es', 0),
        -- Dumbbell chest
        ('Press de Banca Mancuernas',         'Push', 'Chest',      'es', 0),
        ('Press Inclinado Mancuernas',        'Push', 'Chest',      'es', 0),
        ('Press Declinado Mancuernas',        'Push', 'Chest',      'es', 0),
        ('Aperturas Inclinadas',              'Push', 'Chest',      'es', 0),
        -- Dumbbell shoulders
        ('Press Arnold',                      'Push', 'Shoulders',  'es', 0),
        ('Pájaro con Mancuernas',             'Pull', 'Shoulders',  'es', 0),
        -- Dumbbell triceps
        ('Patada de Tríceps',                 'Push', 'Triceps',    'es', 0),
        ('Extensión de Tríceps sobre Cabeza', 'Push', 'Triceps',    'es', 0),
        -- Dumbbell back
        ('Encogimientos con Mancuernas',      'Pull', 'Upper Back', 'es', 0),
        ('Pullover con Mancuerna',            'Pull', 'Upper Back', 'es', 0),
        -- Dumbbell biceps
        ('Curl de Bíceps Mancuernas',         'Pull', 'Biceps',     'es', 0),
        ('Curl de Concentración',             'Pull', 'Biceps',     'es', 0),
        ('Curl en Banco Scott',               'Pull', 'Biceps',     'es', 0),
        -- Dumbbell hinge
        ('Peso Muerto Rumano Mancuernas',     'Hinge', 'Hamstrings', 'es', 0),
        ('Empuje de Cadera Mancuernas',       'Hinge', 'Glutes',     'es', 0),
        -- Dumbbell squat / lunge
        ('Sentadilla con Mancuernas',         'Squat', 'Quads',  'es', 0),
        ('Estocada con Mancuernas',           'Lunge', 'Quads',  'es', 0),
        ('Sentadilla Búlgara Mancuernas',     'Lunge', 'Glutes', 'es', 0),
        ('Step-up con Mancuernas',            'Lunge', 'Quads',  'es', 0)
      '''
    ],
    4: [
      '''
      INSERT OR IGNORE INTO exercises (name, category, muscle_focus, created_at) VALUES
        -- Dumbbell chest
        ('Dumbbell Bench Press',         'Push', 'Chest',      0),
        ('Dumbbell Incline Press',        'Push', 'Chest',      0),
        ('Dumbbell Decline Press',        'Push', 'Chest',      0),
        ('Incline Dumbbell Fly',          'Push', 'Chest',      0),
        -- Dumbbell shoulders
        ('Dumbbell Arnold Press',         'Push', 'Shoulders',  0),
        ('Dumbbell Reverse Fly',          'Pull', 'Shoulders',  0),
        -- Dumbbell triceps
        ('Dumbbell Tricep Kickback',      'Push', 'Triceps',    0),
        ('Dumbbell Overhead Tricep Ext',  'Push', 'Triceps',    0),
        -- Dumbbell back
        ('Dumbbell Shrug',                'Pull', 'Upper Back', 0),
        ('Dumbbell Pullover',             'Pull', 'Upper Back', 0),
        -- Dumbbell biceps
        ('Dumbbell Bicep Curl',           'Pull', 'Biceps',     0),
        ('Concentration Curl',            'Pull', 'Biceps',     0),
        ('Preacher Curl',                 'Pull', 'Biceps',     0),
        -- Dumbbell hinge / posterior chain
        ('Dumbbell Romanian Deadlift',    'Hinge', 'Hamstrings', 0),
        ('Dumbbell Hip Thrust',           'Hinge', 'Glutes',     0),
        -- Dumbbell squat / lunge
        ('Dumbbell Squat',                'Squat', 'Quads',  0),
        ('Dumbbell Lunge',                'Lunge', 'Quads',  0),
        ('Dumbbell Bulgarian Split Squat','Lunge', 'Glutes', 0),
        ('Dumbbell Step-up',              'Lunge', 'Quads',  0)
      '''
    ],
  };
}
