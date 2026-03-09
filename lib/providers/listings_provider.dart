import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/listing.dart';

enum ListingsStatus { initial, loading, loaded, error }

class ListingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  ListingsStatus _status = ListingsStatus.initial;
  List<Listing> _allListings = [];
  List<Listing> _myListings = [];
  List<Listing> _filteredListings = [];
  List<Review> _reviews = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String? _errorMessage;

  StreamSubscription<List<Listing>>? _listingsSubscription;
  StreamSubscription<List<Listing>>? _myListingsSubscription;
  StreamSubscription<List<Review>>? _reviewsSubscription;

  ListingsProvider(this._firestoreService);

  // Getters
  ListingsStatus get status => _status;
  List<Listing> get listings => _filteredListings;
  List<Listing> get myListings => _myListings;
  List<Review> get reviews => _reviews;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ListingsStatus.loading;

  // Initialize and subscribe to listings stream
  void initListings() {
    _status = ListingsStatus.loading;
    notifyListeners();

    _listingsSubscription?.cancel();
    _listingsSubscription = _firestoreService.listingsStream().listen(
      (listings) {
        _allListings = listings;
        _applyFilters();
        _status = ListingsStatus.loaded;
        notifyListeners();
      },
      onError: (e) {
        _status = ListingsStatus.error;
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  // Load user's listings
  void initMyListings(String uid) {
    _myListingsSubscription?.cancel();
    _myListingsSubscription = _firestoreService.myListingsStream(uid).listen(
      (listings) {
        _myListings = listings;
        notifyListeners();
      },
    );
  }

  // Subscribe to reviews for a listing
  void subscribeToReviews(String listingId) {
    _reviewsSubscription?.cancel();
    _reviewsSubscription =
        _firestoreService.reviewsStream(listingId).listen((reviews) {
      _reviews = reviews;
      notifyListeners();
    });
  }

  // Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to listings
  void _applyFilters() {
    var result = _allListings;

    // Category filter
    if (_selectedCategory != 'All') {
      result = result.where((l) => l.category == _selectedCategory).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      result = result
          .where((l) =>
              l.name.toLowerCase().contains(lower) ||
              l.address.toLowerCase().contains(lower) ||
              l.category.toLowerCase().contains(lower))
          .toList();
    }

    _filteredListings = result;
  }

  // CRUD operations
  Future<bool> createListing(Listing listing) async {
    try {
      await _firestoreService.createListing(listing);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(Listing listing) async {
    try {
      await _firestoreService.updateListing(listing);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _firestoreService.deleteListing(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addReview(Review review) async {
    try {
      await _firestoreService.addReview(review);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _listingsSubscription?.cancel();
    _myListingsSubscription?.cancel();
    _reviewsSubscription?.cancel();
    super.dispose();
  }
}
