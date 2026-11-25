const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _monthsLong = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _daysLong = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

String two(int n) => n.toString().padLeft(2, '0');
String monthShort(DateTime d) => _months[d.month - 1];
String weekdayShort(DateTime d) => _days[d.weekday - 1];

/// 09:30
String fmtTime(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

/// 4:30 PM
String fmtTime12(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$h:${two(d.minute)} ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// Tue, 20 May
String fmtDate(DateTime d) => '${weekdayShort(d)}, ${d.day} ${monthShort(d)}';

/// 20 May 2026
String fmtDateLong(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// Tuesday, 20 May 2026
String fmtDateFull(DateTime d) => '${_daysLong[d.weekday - 1]}, ${d.day} ${_monthsLong[d.month - 1]} ${d.year}';

String fmtRange(DateTime a, DateTime b) {
  if (sameDay(a, b)) return '${fmtDate(a)} · ${fmtTime(a)}–${fmtTime(b)}';
  if (a.month == b.month) return '${a.day}–${b.day} ${monthShort(a)} ${a.year}';
  return '${a.day} ${monthShort(a)} – ${b.day} ${monthShort(b)} ${b.year}';
}

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.isNegative) return 'soon';
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return fmtDateLong(d);
}

/// Short chat timestamp: 14:05, Yesterday, 12 May
String chatStamp(DateTime d) {
  final now = DateTime.now();
  if (sameDay(d, now)) return fmtTime(d);
  if (sameDay(d, now.subtract(const Duration(days: 1)))) return 'Yesterday';
  return '${d.day} ${monthShort(d)}';
}

String fmtSize(double mb) => mb >= 1 ? '${mb.toStringAsFixed(1)} MB' : '${(mb * 1024).round()} KB';

String countdown(DateTime start) {
  final diff = start.difference(DateTime.now());
  if (diff.isNegative) return 'Started';
  if (diff.inDays >= 1) return 'in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
  if (diff.inHours >= 1) return 'in ${diff.inHours}h';
  return 'in ${diff.inMinutes}m';
}
