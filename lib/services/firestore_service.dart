import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _listingsCollection = 'listings';
  static const String _reviewsCollection = 'reviews';

  // ── LISTINGS ──────────────────────────────────────────────

  // Real-time stream of all listings
  Stream<List<Listing>> listingsStream() {
    return _db
        .collection(_listingsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Listing.fromFirestore).toList());
  }

  // Real-time stream filtered by category
  Stream<List<Listing>> listingsByCategoryStream(String category) {
    if (category == 'All') return listingsStream();
    return _db
        .collection(_listingsCollection)
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Listing.fromFirestore).toList());
  }

  // Listings by current user
  Stream<List<Listing>> myListingsStream(String uid) {
    return _db
        .collection(_listingsCollection)
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Listing.fromFirestore).toList());
  }

  // Get single listing
  Future<Listing?> getListing(String id) async {
    final doc = await _db.collection(_listingsCollection).doc(id).get();
    if (doc.exists) return Listing.fromFirestore(doc);
    return null;
  }

  // Create listing
  Future<String> createListing(Listing listing) async {
    final ref = await _db
        .collection(_listingsCollection)
        .add(listing.toFirestore());
    return ref.id;
  }

  // Update listing
  Future<void> updateListing(Listing listing) async {
    await _db
        .collection(_listingsCollection)
        .doc(listing.id)
        .update(listing.toFirestore());
  }

  // Delete listing
  Future<void> deleteListing(String id) async {
    final batch = _db.batch();
    
    // Delete the listing
    batch.delete(_db.collection(_listingsCollection).doc(id));
    
    // Delete associated reviews
    final reviews = await _db
        .collection(_reviewsCollection)
        .where('listingId', isEqualTo: id)
        .get();
    for (final doc in reviews.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  // Search listings by name (client-side for simplicity)
  Future<List<Listing>> searchListings(String query) async {
    final snap = await _db.collection(_listingsCollection).get();
    final all = snap.docs.map(Listing.fromFirestore).toList();
    final lower = query.toLowerCase();
    return all
        .where((l) =>
            l.name.toLowerCase().contains(lower) ||
            l.category.toLowerCase().contains(lower) ||
            l.address.toLowerCase().contains(lower))
        .toList();
  }

  // ── REVIEWS ──────────────────────────────────────────────

  Stream<List<Review>> reviewsStream(String listingId) {
    return _db
        .collection(_reviewsCollection)
        .where('listingId', isEqualTo: listingId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Review.fromFirestore).toList());
  }

  Future<void> addReview(Review review) async {
    final batch = _db.batch();
    
    // Add review
    final reviewRef = _db.collection(_reviewsCollection).doc();
    batch.set(reviewRef, review.toFirestore());

    // Update listing average rating
    final listingRef = _db.collection(_listingsCollection).doc(review.listingId);
    final listingDoc = await listingRef.get();
    if (listingDoc.exists) {
      final data = listingDoc.data() as Map<String, dynamic>;
      final currentRating = (data['rating'] ?? 0.0).toDouble();
      final currentCount = (data['reviewCount'] ?? 0) as int;
      final newCount = currentCount + 1;
      final newRating = ((currentRating * currentCount) + review.rating) / newCount;
      batch.update(listingRef, {
        'rating': newRating,
        'reviewCount': newCount,
      });
    }

    await batch.commit();
  }
}
