import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/listing_card.dart';
import '../directory/add_edit_listing_screen.dart';
import '../directory/listing_detail_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>().myListings;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppTheme.accentGold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddEditListingScreen()),
            ),
          ),
        ],
      ),
      body: listings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.bookmark_border,
                        color: AppTheme.accentGold, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text('No listings yet',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'Add a location to share it\nwith the Kigali community',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddEditListingScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Listing'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: listings.length,
              itemBuilder: (_, i) {
                final listing = listings[i];
                return ListingCard(
                  listing: listing,
                  showActions: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ListingDetailScreen(listing: listing),
                    ),
                  ),
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditListingScreen(listing: listing),
                    ),
                  ),
                  onDelete: () => _confirmDelete(context, listing.id),
                );
              },
            ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Listing',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Are you sure you want to delete this listing? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ListingsProvider>().deleteListing(id);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
