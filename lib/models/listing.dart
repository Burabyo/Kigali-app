import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;
  final double rating;
  final int reviewCount;

  Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? -1.9403).toDouble(),
      longitude: (data['longitude'] ?? 29.8739).toDouble(),
      createdBy: data['createdBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: (data['reviewCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  Listing copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
    double? rating,
    int? reviewCount,
  }) {
    return Listing(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  String get distanceText => '${(latitude * longitude % 2).abs().toStringAsFixed(1)} km';
}

class Review {
  final String id;
  final String listingId;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      listingId: data['listingId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'listingId': listingId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
