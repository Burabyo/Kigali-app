import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/listing.dart';
import '../../providers/listings_provider.dart';
import '../../utils/theme.dart';
import '../directory/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Listing? _selectedListing;

  static const LatLng _kigaliCenter = LatLng(-1.9403, 29.8739);

  Set<Marker> _buildMarkers(List<Listing> listings) {
    return listings.map((l) {
      return Marker(
        markerId: MarkerId(l.id),
        position: LatLng(l.latitude, l.longitude),
        infoWindow: InfoWindow(title: l.name, snippet: l.category),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () => setState(() => _selectedListing = l),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>().listings;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Map View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  const CameraPosition(target: _kigaliCenter, zoom: 13),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _kigaliCenter,
              zoom: 13,
            ),
            markers: _buildMarkers(listings),
            onMapCreated: (ctrl) => _mapController = ctrl,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onTap: (_) => setState(() => _selectedListing = null),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: AppTheme.accentGold, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${listings.length} places',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedListing != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _SelectedListingCard(
                listing: _selectedListing!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListingDetailScreen(listing: _selectedListing!),
                  ),
                ),
                onClose: () => setState(() => _selectedListing = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectedListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _SelectedListingCard({
    required this.listing,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _emoji(listing.category),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(listing.category,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.accentGold, size: 14),
                      const SizedBox(width: 4),
                      Text(listing.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close, color: AppTheme.textMuted, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  String _emoji(String cat) {
    const m = {
      'Café': '☕', 'Restaurant': '🍽️', 'Hospital': '🏥',
      'Police Station': '🚔', 'Library': '📚', 'Park': '🌳',
      'Tourist Attraction': '🏛️', 'Pharmacy': '💊', 'Bank': '🏦',
      'Supermarket': '🛒', 'Hotel': '🏨', 'Gym': '💪',
      'School': '🎓', 'Utility Office': '🏢',
    };
    return m[cat] ?? '📍';
  }
}