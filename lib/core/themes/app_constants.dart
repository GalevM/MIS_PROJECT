class AppConstants {
  static const String appName = 'Општина Карпош';

  // Firestore collections
  static const reportsCol = 'reports';
  static const usersCol = 'users';
  static const reportImagesPath = 'reports/images';
  static const String notificationsCol = 'notifications';
  static const String pollsCol = 'polls';
  static const String pollVotesCol = 'poll_votes';

  // Report statuses
  static const String statusReceived = 'received';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';

  // Report categories
  static const List<Map<String, String>> categories = [
    {'value': 'road', 'label': 'Дупка на пат', 'emoji': '🚧'},
    {'value': 'garbage', 'label': 'Ѓубре', 'emoji': '🗑️'},
    {'value': 'lighting', 'label': 'Улично светло', 'emoji': '💡'},
    {'value': 'illegal_dump', 'label': 'Дива депонија', 'emoji': '⚠️'},
    {'value': 'park', 'label': 'Парк / зеленило', 'emoji': '🌳'},
    {'value': 'water', 'label': 'Водоснабдување', 'emoji': '💧'},
    {'value': 'other', 'label': 'Друго', 'emoji': '📌'},
  ];

  // User roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  // Storage paths
  static const String avatarsPath = 'avatars';

  // Points per action
  static const int pointsReport = 10;
  static const int pointsVote = 5;
}