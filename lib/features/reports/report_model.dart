class ReportModel {
  final String id;
  final String userId;
  final String category;
  final String description;
  final String imageUrl;
  final String status;

  ReportModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'status': status,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'],
      userId: map['userId'],
      category: map['category'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      status: map['status'],
    );
  }
}