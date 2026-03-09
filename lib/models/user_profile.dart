import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final DateTime createdAt;
  final bool notificationsEnabled;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber = '',
    required this.createdAt,
    this.notificationsEnabled = true,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationsEnabled': notificationsEnabled,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? phoneNumber,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
