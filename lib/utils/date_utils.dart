// lib/utils/date_utils.dart

String formatDate(DateTime? date) {
  if (date == null) return "لا يوجد";
  return "${date.day}-${date.month}-${date.year}";
}

String formatTimeAgo(DateTime timestamp) {
  Duration difference = DateTime.now().difference(timestamp);
  if (difference.inMinutes < 1) return "الآن";
  if (difference.inMinutes < 60) return "${difference.inMinutes} دقيقة";
  if (difference.inHours < 24) return "${difference.inHours} ساعة";
  if (difference.inDays < 7) return "${difference.inDays} يوم";
  return "${difference.inDays ~/ 7} أسبوع";
}