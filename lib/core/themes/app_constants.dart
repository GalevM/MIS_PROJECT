class AppConstants {
  static const String appName = 'Општина Карпош';

  static const reportsCol = 'reports';
  static const usersCol = 'users';
  static const reportImagesPath = 'reports/images';
  static const String notificationsCol = 'notifications';
  static const String pollsCol = 'polls';
  static const String pollVotesCol = 'poll_votes';

  static const String statusReceived = 'received';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';

  static const List<Map<String, String>> categories = [
    {'value': 'road', 'label': 'Дупка на пат', 'emoji': '🚧'},
    {'value': 'lighting', 'label': 'Улично светло', 'emoji': '💡'},
    {'value': 'illegal_dump', 'label': 'Дива депонија', 'emoji': '⚠️'},
    {'value': 'park', 'label': 'Парк / зеленило', 'emoji': '🌳'},
    {'value': 'garbage', 'label': 'Ѓубре', 'emoji': '🗑️'},
    {'value': 'water', 'label': 'Водоснабдување', 'emoji': '💧'},
    {'value': 'other', 'label': 'Друго', 'emoji': '📌'},
  ];

  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  static const String avatarsPath = 'avatars';

  static const int pointsReport = 10;
  static const int pointsVote = 5;
}
