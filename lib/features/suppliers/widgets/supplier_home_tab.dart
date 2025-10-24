import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../supplier_model.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/widgets/video/video_player_widget.dart';
import '../../b2b/widgets/shared/certificate_card.dart';
import '../../b2b/widgets/shared/exhibition_card.dart';
import '../../b2b/widgets/shared/brand_logo.dart';
import '../../b2b/widgets/shared/section_title.dart';

class SupplierHomeTab extends StatelessWidget {
  final B2BSupplier supplier;
  final AppThemeData theme;

  const SupplierHomeTab({
    super.key,
    required this.supplier,
    required this.theme,
  });

  void _showVideoDialog(BuildContext context) {
    const videoUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VideoPlayerWidget(
          videoUrl: videoUrl,
          title: 'Company Introduction Video',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Video Showcase
          _buildSection(
            theme,
            'Company Video Showcase',
            GestureDetector(
              onTap: () => _showVideoDialog(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: theme.inputBackground,
                        height: 200,
                      ),
                    ),
                    Container(
                      height: 200,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 48,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // About Us
          _buildSection(
            theme,
            'About Us',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global Electronics Ltd is a leading manufacturer and exporter of high-quality electronic products. Established in ${DateTime.now().year - supplier.yearsInBusiness}, we have been serving customers worldwide with innovative solutions and exceptional service.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textPrimary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Our state-of-the-art manufacturing facilities and experienced team ensure that every product meets international quality standards. We specialize in ${supplier.category} and have successfully delivered to over 50 countries.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          
          // Certificates
          SectionTitle(
            theme: theme,
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
          
          // Exhibition
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              children: [
                Text(
                  'EXHIBITION',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.0,
                  children: const [
                    ExhibitionCard(imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=300'),
                    ExhibitionCard(imageUrl: 'https://images.unsplash.com/photo-1591115765373-5207764f72e7?w=300'),
                    ExhibitionCard(imageUrl: 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=300'),
                  ],
                ),
              ],
            ),
          ),
          
          // Collaborative Brands
          _buildSection(
            theme,
            'Collaborative Brands',
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                BrandLogo(imageUrl: 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=100'),
                BrandLogo(imageUrl: 'https://images.unsplash.com/photo-1614680376573-df3480f0c6ff?w=100'),
                BrandLogo(imageUrl: 'https://images.unsplash.com/photo-1599305445671-ac291c95aaa9?w=100'),
                BrandLogo(imageUrl: 'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=100'),
                BrandLogo(imageUrl: 'https://images.unsplash.com/photo-1611162618071-b39a2ec055fb?w=100'),
                BrandLogo(imageUrl: 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=100'),
              ],
            ),
          ),
          
          // Contact Sales Manager
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Text(
                  'Contact Sales Manager',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.primary.withOpacity(0.1),
                      child: Text(
                        'AK',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Abebe Kebede',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sales Manager',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+251 911 234 567',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.phone, color: theme.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.primary.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.message, color: theme.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(AppThemeData theme, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
