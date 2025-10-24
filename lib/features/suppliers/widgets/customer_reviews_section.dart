import 'package:flutter/material.dart';
import '../../../shared/utils/theme/app_themes.dart';

class CustomerReviewsSection extends StatelessWidget {
  final AppThemeData theme;
  final int selectedRating;
  final Function(int) onRatingChanged;

  const CustomerReviewsSection({
    super.key,
    required this.theme,
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final allReviews = [
      {'name': 'John Smith', 'country': 'USA', 'rating': 5, 'review': 'Excellent quality products and fast shipping. Very professional supplier!', 'time': '2 weeks ago'},
      {'name': 'Maria Garcia', 'country': 'Spain', 'rating': 5, 'review': 'Great communication and reliable delivery. Highly recommended!', 'time': '1 month ago'},
      {'name': 'Ahmed Hassan', 'country': 'Egypt', 'rating': 4, 'review': 'Good products at competitive prices. Will order again.', 'time': '2 months ago'},
      {'name': 'Li Wei', 'country': 'China', 'rating': 5, 'review': 'Outstanding service and product quality. Very satisfied with our partnership.', 'time': '3 months ago'},
      {'name': 'Sarah Johnson', 'country': 'UK', 'rating': 4, 'review': 'Reliable supplier with good product range.', 'time': '3 months ago'},
    ];
    
    final filteredReviews = selectedRating == 0 
        ? allReviews 
        : allReviews.where((r) => r['rating'] == selectedRating).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Rating Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRatingFilter(0, 'All'),
                const SizedBox(width: 8),
                _buildRatingFilter(5, '5 ⭐'),
                const SizedBox(width: 8),
                _buildRatingFilter(4, '4 ⭐'),
                const SizedBox(width: 8),
                _buildRatingFilter(3, '3 ⭐'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...filteredReviews.map((review) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReviewCard(
              review['name'] as String,
              review['country'] as String,
              review['rating'] as int,
              review['review'] as String,
              review['time'] as String,
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRatingFilter(int rating, String label) {
    final isSelected = selectedRating == rating;
    return GestureDetector(
      onTap: () => onRatingChanged(rating),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : theme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : theme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(String name, String country, int rating, String review, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.primary.withOpacity(0.1),
                child: Text(
                  name[0],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      country,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: TextStyle(
              fontSize: 13,
              color: theme.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
