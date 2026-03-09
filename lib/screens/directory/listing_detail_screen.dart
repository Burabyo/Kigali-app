import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/theme.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ListingsProvider>().subscribeToReviews(widget.listing.id);
  }

  void _launchNavigation() async {
    final lat = widget.listing.latitude;
    final lng = widget.listing.longitude;
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _callNumber() async {
    final uri = Uri(scheme: 'tel', path: widget.listing.contactNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showReviewDialog() {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    double selectedRating = 4;
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Write a Review',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedRating = i + 1.0),
                    child: Icon(
                      i < selectedRating ? Icons.star : Icons.star_border,
                      color: AppTheme.accentGold,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Share your experience...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (commentCtrl.text.trim().isEmpty) return;
                    final review = Review(
                      id: '',
                      listingId: widget.listing.id,
                      userId: auth.user!.uid,
                      userName: auth.userProfile?.displayName ?? 'Anonymous',
                      comment: commentCtrl.text.trim(),
                      rating: selectedRating,
                      timestamp: DateTime.now(),
                    );
                    await context.read<ListingsProvider>().addReview(review);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final reviews = context.watch<ListingsProvider>().reviews;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(listing.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(listing.latitude, listing.longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('listing'),
                    position: LatLng(listing.latitude, listing.longitude),
                    infoWindow: InfoWindow(title: listing.name),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange),
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing.name,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              '${listing.category} · ${listing.distanceText}',
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.accentGold.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: AppTheme.accentGold, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              listing.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    listing.description,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  _infoTile(Icons.location_on_outlined, 'Address', listing.address),
                  const SizedBox(height: 10),
                  _infoTile(Icons.phone_outlined, 'Contact', listing.contactNumber),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _launchNavigation,
                          icon: const Icon(Icons.directions, size: 18),
                          label: const Text('Navigate'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _callNumber,
                        icon: const Icon(Icons.call_outlined,
                            size: 18, color: AppTheme.textSecondary),
                        label: const Text('Call',
                            style: TextStyle(color: AppTheme.textSecondary)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.divider),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Text('Reviews',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _showReviewDialog,
                        icon: const Icon(Icons.rate_review_outlined, size: 16),
                        label: const Text('Rate this service'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Av. ${listing.rating.toStringAsFixed(1)} rating  ·  ${listing.reviewCount} reviews',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (reviews.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('No reviews yet. Be the first!',
                            style: TextStyle(color: AppTheme.textMuted)),
                      ),
                    )
                  else
                    ...reviews.map((r) => _ReviewTile(review: r)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
                Text(value,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.accentGold.withOpacity(0.2),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Text(review.userName,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    color: AppTheme.accentGold,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('"${review.comment}"',
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}