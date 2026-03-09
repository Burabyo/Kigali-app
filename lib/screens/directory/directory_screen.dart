import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'add_edit_listing_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Column(
          children: [
            Text('Kigali City',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            Text('Services Directory',
                style:
                    TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentGold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddEditListingScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(),
          _CategoryBar(),
          const Expanded(child: _ListingsList()),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        style: const TextStyle(color: AppTheme.textPrimary),
        onChanged: (v) => context.read<ListingsProvider>().setSearchQuery(v),
        decoration: const InputDecoration(
          hintText: 'Search for a service...',
          prefixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: AppConstants.categories.length,
        itemBuilder: (_, i) {
          final cat = AppConstants.categories[i];
          return CategoryChip(
            label: cat,
            isSelected: provider.selectedCategory == cat,
            onTap: () => provider.setCategory(cat),
          );
        },
      ),
    );
  }
}

class _ListingsList extends StatelessWidget {
  const _ListingsList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      );
    }

    if (provider.listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: AppTheme.textMuted, size: 56),
            const SizedBox(height: 12),
            const Text('No listings found',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              provider.searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Be the first to add a listing!',
              style:
                  const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: provider.listings.length,
      itemBuilder: (_, i) {
        final listing = provider.listings[i];
        return ListingCard(
          listing: listing,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing),
            ),
          ),
        );
      },
    );
  }
}
