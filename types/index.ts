export interface Trainee {
  id: number;
  name: string;
  notes: string | null;
  created_at: number;
}

export interface Exercise {
  id: number;
  name: string;
  category: string | null;
  created_at: number;
}

export interface PlanDay {
  id: number;
  trainee_id: number;
  weekday: number; // 0=Mon...6=Sun
  label: string | null;
}

export interface PlanDayExercise {
  id: number;
  plan_day_id: number;
  exercise_id: number;
  order_index: number;
  notes: string | null;
  // joined fields:
  exercise_name: string;
  exercise_category: string | null;
}

export interface Session {
  id: number;
  trainee_id: number;
  plan_day_id: number | null;
  date: string; // YYYY-MM-DD
  notes: string | null;
  started_at: number | null;
  ended_at: number | null;
}

export interface SessionExercise {
  id: number;
  session_id: number;
  exercise_id: number;
  order_index: number;
  notes: string | null;
  exercise_name: string;
  exercise_category: string | null;
}

export interface ExerciseSet {
  id: number;
  session_exercise_id: number;
  set_number: number;
  reps: number | null;
  weight_kg: number | null;
  duration_seconds: number | null;
  completed: number; // 0 or 1
}

export interface SessionWithDetail extends Session {
  exercises: SessionExerciseWithSets[];
}

export interface SessionExerciseWithSets extends SessionExercise {
  sets: ExerciseSet[];
}

export type Weekday = 0 | 1 | 2 | 3 | 4 | 5 | 6;

export interface ProgressPoint {
  date: string;
  session_id: number;
  best_weight: number | null;
  best_reps: number | null;
  estimated_1rm: number | null;
  best_duration: number | null;
}

export interface ExercisePR {
  exercise_id: number;
  exercise_name: string;
  pr_weight: number | null;
  pr_1rm: number | null;
  pr_reps: number | null;
  pr_duration: number | null;
  session_count: number;
}
