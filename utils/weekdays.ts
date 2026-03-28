export const WEEKDAY_NAMES: Record<number, string> = {
  0: 'Monday',
  1: 'Tuesday',
  2: 'Wednesday',
  3: 'Thursday',
  4: 'Friday',
  5: 'Saturday',
  6: 'Sunday',
};

export const WEEKDAY_SHORT: Record<number, string> = {
  0: 'Mon', 1: 'Tue', 2: 'Wed', 3: 'Thu', 4: 'Fri', 5: 'Sat', 6: 'Sun',
};

export function getTodayWeekday(): number {
  // 0=Mon...6=Sun (JS getDay: 0=Sun,1=Mon..6=Sat)
  const day = new Date().getDay();
  return day === 0 ? 6 : day - 1;
}
