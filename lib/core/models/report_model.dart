import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String userId;
  final String userFullName;
  final String category;
  final String description;
  final String status;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminNote;

  const ReportModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.category,
    required this.description,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.imageUrls,
    required this.createdAt,
    this.updatedAt,
    this.adminNote,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userFullName: data['userFullName'] ?? 'Анонимен',
      category: data['category'] ?? 'other',
      description: data['description'] ?? '',
      status: data['status'] ?? 'received',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      address: data['address'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      adminNote: data['adminNote'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'userFullName': userFullName,
    'category': category,
    'description': description,
    'status': status,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'imageUrls': imageUrls,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': null,
    'adminNote': null,
  };

  ReportModel copyWith({String? status, String? adminNote}) => ReportModel(
    id: id,
    userId: userId,
    userFullName: userFullName,
    category: category,
    description: description,
    status: status ?? this.status,
    latitude: latitude,
    longitude: longitude,
    address: address,
    imageUrls: imageUrls,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    adminNote: adminNote ?? this.adminNote,
  );
}
