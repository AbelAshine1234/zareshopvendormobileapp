import 'package:flutter/material.dart';
import '../supplier_model.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../b2b/widgets/shared/certificate_card.dart';
import '../../b2b/widgets/shared/section_title.dart';
import 'company_info_section.dart';
import 'customer_reviews_section.dart';

class SupplierProfileTab extends StatefulWidget {
  final B2BSupplier supplier;
  final AppThemeData theme;

  const SupplierProfileTab({
    super.key,
    required this.supplier,
    required this.theme,
  });

  @override
  State<SupplierProfileTab> createState() => _SupplierProfileTabState();
}

class _SupplierProfileTabState extends State<SupplierProfileTab> {
  int _selectedRating = 0; // 0 = all ratings

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Overview
          CompanyInfoSection(
            supplier: widget.supplier,
            theme: widget.theme,
          ),
          
          // Certifications
          SectionTitle(
            theme: widget.theme,
            title: 'CERTIFICATES',
            subtitle: 'Authoritative certification / worry-free quality',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
              children: const [
                CertificateCard(
                  imageUrl: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=300',
                  label: 'ISO14001',
                ),
                CertificateCard(
                  imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=300',
                  label: 'ISO9001',
                ),
                CertificateCard(
                  imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=300',
                  label: 'UL',
                ),
                CertificateCard(
                  imageUrl: 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=300',
                  label: 'IATF 16949',
                ),
                CertificateCard(
                  imageUrl: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=300',
                  label: 'IECQ QC 080000',
                ),
              ],
            ),
          ),
          
          // Customer Reviews
          CustomerReviewsSection(
            theme: widget.theme,
            selectedRating: _selectedRating,
            onRatingChanged: (rating) => setState(() => _selectedRating = rating),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
