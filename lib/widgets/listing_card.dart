import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../utils/theme.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Center(
                  child: Text(
                    _categoryEmoji(listing.category),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showActions) ...[
                          GestureDetector(
                            onTap: onEdit,
                            child: const Icon(Icons.edit_outlined,
                                color: AppTheme.accentGold, size: 18),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: onDelete,
                            child: const Icon(Icons.delete_outline,
                                color: AppTheme.error, size: 18),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Stars + review count
                    Row(
                      children: [
                        _buildStars(listing.rating),
                        const SizedBox(width: 6),
                        Text(
                          listing.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Category & distance
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            listing.category,
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.location_on_outlined,
                            color: AppTheme.textMuted, size: 13),
                        Text(
                          listing.distanceText,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: AppTheme.accentGold, size: 14);
        } else if (index < rating) {
          return const Icon(Icons.star_half,
              color: AppTheme.accentGold, size: 14);
        } else {
          return const Icon(Icons.star_border,
              color: AppTheme.textMuted, size: 14);
        }
      }),
    );
  }

  String _categoryEmoji(String category) {
    const icons = {
      'Café': '☕',
      'Restaurant': '🍽️',
      'Hospital': '🏥',
      'Police Station': '🚔',
      'Library': '📚',
      'Park': '🌳',
      'Tourist Attraction': '🏛️',
      'Pharmacy': '💊',
      'Bank': '🏦',
      'Supermarket': '🛒',
      'Hotel': '🏨',
      'Gym': '💪',
      'School': '🎓',
      'Utility Office': '🏢',
    };
    return icons[category] ?? '📍';
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGold : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : AppTheme.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryDark : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
