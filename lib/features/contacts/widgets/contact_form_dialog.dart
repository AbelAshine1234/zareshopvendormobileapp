import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/utils/theme/theme_provider.dart';

class ContactFormDialog extends StatefulWidget {
  final Map<String, dynamic>? contact;
  final Function(Map<String, dynamic>) onSave;

  const ContactFormDialog({super.key, this.contact, required this.onSave});

  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ratingController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  // Dynamic phone numbers list
  final List<Map<String, String>> _phoneNumbers = [];
  final _twitterController = TextEditingController();
  final _telegramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _blueskyController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _tiktokController = TextEditingController();

  // Social media section state
  bool _isSocialMediaExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!['name'] ?? '';
      _descriptionController.text = widget.contact!['description'] ?? '';
      _ratingController.text = widget.contact!['rating'] ?? '';
      _emailController.text = widget.contact!['email'] ?? '';
      _websiteController.text = widget.contact!['website'] ?? '';

      // Initialize phone numbers from contact data
      _initializePhoneNumbers();
      _twitterController.text = widget.contact!['twitter_link'] ?? '';
      _telegramController.text = widget.contact!['telegram_link'] ?? '';
      _facebookController.text = widget.contact!['facebook_link'] ?? '';
      _youtubeController.text = widget.contact!['youtube_link'] ?? '';
      _blueskyController.text = widget.contact!['bluesky_link'] ?? '';
      _instagramController.text = widget.contact!['instagram_link'] ?? '';
      _linkedinController.text = widget.contact!['linkedin_link'] ?? '';
      _tiktokController.text = widget.contact!['tiktok_link'] ?? '';
      
      // Check if there are any existing social media links to expand the section
      _isSocialMediaExpanded = _hasAnySocialMediaLinks();
    }
  }

  void _initializePhoneNumbers() {
    _phoneNumbers.clear();
    // Add existing phone numbers
    for (int i = 1; i <= 4; i++) {
      final phone = widget.contact!['phone$i'];
      if (phone != null && phone.isNotEmpty) {
        _phoneNumbers.add({
          'id': 'phone$i',
          'number': phone,
          'label': _getPhoneLabel(i),
        });
      }
    }
  }

  String _getPhoneLabel(int index) {
    switch (index) {
      case 1:
        return 'Primary';
      case 2:
        return 'Secondary';
      case 3:
        return 'Additional';
      case 4:
        return 'Emergency';
      default:
        return 'Phone $index';
    }
  }

  void _addPhoneNumber() {
    setState(() {
      _phoneNumbers.add({
        'id': 'phone${_phoneNumbers.length + 1}',
        'number': '',
        'label': _getPhoneLabel(_phoneNumbers.length + 1),
      });
    });
  }

  void _removePhoneNumber(int index) {
    setState(() {
      _phoneNumbers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ratingController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _twitterController.dispose();
    _telegramController.dispose();
    _facebookController.dispose();
    _youtubeController.dispose();
    _blueskyController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  bool _hasAnySocialMediaLinks() {
    return _twitterController.text.isNotEmpty ||
        _telegramController.text.isNotEmpty ||
        _facebookController.text.isNotEmpty ||
        _youtubeController.text.isNotEmpty ||
        _blueskyController.text.isNotEmpty ||
        _instagramController.text.isNotEmpty ||
        _linkedinController.text.isNotEmpty ||
        _tiktokController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'contacts.updateInfo'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Form
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Name Field (Read-only)
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'contacts.businessName'.tr(),
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                        ),
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      // Description Field (Read-only)
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'contacts.description'.tr(),
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                        ),
                        maxLines: 3,
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      // Rating Field (Read-only)
                      TextFormField(
                        controller: _ratingController,
                        decoration: InputDecoration(
                          labelText: 'contacts.rating'.tr(),
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                        ),
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      const SizedBox(height: 20),

                       // Email Section
                       TextFormField(
                         controller: _emailController,
                         decoration: InputDecoration(
                           labelText: 'contacts.emailAddress'.tr(),
                           border: const OutlineInputBorder(),
                           prefixIcon: const Icon(Icons.email, color: Colors.blue),
                           hintText: 'example@email.com',
                         ),
                         keyboardType: TextInputType.emailAddress,
                         validator: (value) {
                           if (value == null || value.isEmpty) {
                             return null; // Allow empty email
                           }
                           if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                             return 'validation.emailInvalid'.tr();
                           }
                           return null;
                         },
                       ),
                      const SizedBox(height: 16),

                       // Website Section
                       TextFormField(
                         controller: _websiteController,
                         decoration: InputDecoration(
                           labelText: 'contacts.website'.tr(),
                           border: const OutlineInputBorder(),
                           prefixIcon: const Icon(Icons.language, color: Colors.green),
                           hintText: 'https://www.example.com',
                         ),
                         keyboardType: TextInputType.url,
                         validator: (value) {
                           if (value == null || value.isEmpty) {
                             return null; // Allow empty website
                           }
                           if (!RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$').hasMatch(value)) {
                             return 'validation.websiteInvalid'.tr();
                           }
                           return null;
                         },
                       ),
                      const SizedBox(height: 20),

                       // Phone Numbers Section
                       Consumer<ThemeProvider>(
                         builder: (context, themeProvider, child) {
                           final theme = themeProvider.currentTheme;
                           
                           return Container(
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(color: Colors.grey.shade300),
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Text(
                                       'contacts.phoneNumbers'.tr(),
                                       style: const TextStyle(
                                         fontSize: 16,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.black87,
                                       ),
                                     ),
                                     ElevatedButton.icon(
                                       onPressed: _addPhoneNumber,
                                       icon: const Icon(Icons.add, size: 16),
                                       label: Text('contacts.addPhone'.tr()),
                                       style: ElevatedButton.styleFrom(
                                         backgroundColor: theme.primary,
                                         foregroundColor: Colors.white,
                                         padding: const EdgeInsets.symmetric(
                                           horizontal: 12,
                                           vertical: 8,
                                         ),
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                       ),
                                     ),
                                   ],
                                 ),
                                 const SizedBox(height: 12),

                                 // Dynamic Phone Numbers List
                                 ..._phoneNumbers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final phone = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                             children: [
                               Expanded(
                                 child: Container(
                                   decoration: BoxDecoration(
                                     border: Border.all(color: Colors.grey.shade300),
                                     borderRadius: BorderRadius.circular(8),
                                   ),
                                   child: Row(
                                     children: [
                                       // +251 prefix
                                       Container(
                                         padding: const EdgeInsets.symmetric(
                                           horizontal: 12,
                                           vertical: 16,
                                         ),
                                         decoration: BoxDecoration(
                                           color: theme.primary.withValues(alpha: 0.1),
                                           borderRadius: const BorderRadius.only(
                                             topLeft: Radius.circular(8),
                                             bottomLeft: Radius.circular(8),
                                           ),
                                         ),
                                         child: Row(
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             Icon(
                                               Icons.phone,
                                               color: theme.primary,
                                               size: 16,
                                             ),
                                             const SizedBox(width: 8),
                                             Text(
                                               '+251',
                                               style: TextStyle(
                                                 color: theme.primary,
                                                 fontWeight: FontWeight.w400,
                                                 fontSize: 14,
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                       // Input field
                                       Expanded(
                                         child: TextFormField(
                                           controller: TextEditingController(text: phone['number']),
                                           decoration: InputDecoration(
                                             labelText: phone['label'],
                                             border: InputBorder.none,
                                             contentPadding: const EdgeInsets.symmetric(
                                               horizontal: 12,
                                               vertical: 16,
                                             ),
                                             hintText: '912345678',
                                           ),
                                           keyboardType: TextInputType.phone,
                                           inputFormatters: [
                                             EthiopianPhoneInputFormatter(),
                                           ],
                                           validator: (value) {
                                             if (value == null || value.isEmpty) {
                                               return null;
                                             }
                                             final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
                                             if (cleanValue.length != 9) {
                                               return 'validation.phone9Digits'.tr();
                                             }
                                             if (!cleanValue.startsWith('9')) {
                                               return 'auth.phoneErrorStart'.tr();
                                             }
                                             return null;
                                           },
                                           onChanged: (value) {
                                             _phoneNumbers[index]['number'] = value;
                                           },
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                               const SizedBox(width: 8),
                               IconButton(
                                 onPressed: () => _removePhoneNumber(index),
                                 icon: const Icon(
                                   Icons.remove_circle,
                                   color: Colors.red,
                                 ),
                                 tooltip: 'contacts.removePhone'.tr(),
                               ),
                             ],
                           ),
                         );
                       }),

                       if (_phoneNumbers.isEmpty)
                         Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.grey.shade50,
                             borderRadius: BorderRadius.circular(8),
                             border: Border.all(color: Colors.grey.shade300),
                           ),
                           child: Column(
                             children: [
                               Icon(
                                 Icons.phone_outlined,
                                 size: 32,
                                 color: Colors.grey.shade400,
                               ),
                               const SizedBox(height: 8),
                               Text(
                                 'contacts.noPhoneNumbers'.tr(),
                                 style: const TextStyle(
                                   color: Colors.grey,
                                   fontStyle: FontStyle.italic,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               Text(
                                 'Tap "+ Add Phone" to add phone numbers',
                                 style: TextStyle(
                                   color: Colors.grey.shade500,
                                   fontSize: 12,
                                 ),
                               ),
                             ],
                           ),
                         ),
                               ],
                             ),
                           );
                         },
                       ),
                       const SizedBox(height: 20),

                      // Social Media Section - Collapsible
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Header with expand/collapse button
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isSocialMediaExpanded = !_isSocialMediaExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'contacts.socialMediaLinks'.tr(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Icon(
                                      _isSocialMediaExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Collapsible content
                            if (_isSocialMediaExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                     // Twitter
                                     _buildSocialMediaField(
                                       controller: _twitterController,
                                       label: 'contacts.twitterLink'.tr(),
                                       icon: Icons.alternate_email,
                                       color: Colors.blue,
                                       onClear: () {
                                         setState(() {
                                           _twitterController.clear();
                                         });
                                       },
                                     ),
                                    const SizedBox(height: 12),

                                     // Telegram
                                     _buildSocialMediaField(
                                       controller: _telegramController,
                                       label: 'contacts.telegramLink'.tr(),
                                       icon: Icons.telegram,
                                       color: Colors.blue,
                                       onClear: () {
                                         setState(() {
                                           _telegramController.clear();
                                         });
                                       },
                                     ),
                                    const SizedBox(height: 12),

                                     // Facebook
                                     _buildSocialMediaField(
                                       controller: _facebookController,
                                       label: 'contacts.facebookLink'.tr(),
                                       icon: Icons.facebook,
                                       color: Colors.blue,
                                       onClear: () {
                                         setState(() {
                                           _facebookController.clear();
                                         });
                                       },
                                     ),
                                    const SizedBox(height: 12),

                                     // YouTube
                                     _buildSocialMediaField(
                                       controller: _youtubeController,
                                       label: 'contacts.youtubeLink'.tr(),
                                       icon: Icons.play_circle_fill,
                                       color: Colors.red,
                                       onClear: () {
                                         setState(() {
                                           _youtubeController.clear();
                                         });
                                       },
                                     ),
                                    const SizedBox(height: 12),

                                     // Bluesky
                                     _buildSocialMediaField(
                                       controller: _blueskyController,
                                       label: 'contacts.blueskyLink'.tr(),
                                       icon: Icons.cloud,
                                       color: Colors.blue,
                                       onClear: () {
                                         setState(() {
                                           _blueskyController.clear();
                                         });
                                       },
                                     ),
                                    const SizedBox(height: 12),

                                     // Instagram
                                     _buildSocialMediaField(
                                       controller: _instagramController,
                                       label: 'contacts.instagramLink'.tr(),
                                       icon: Icons.camera_alt,
                                       color: Colors.pink,
                                       onClear: () {
                                         setState(() {
                                           _instagramController.clear();
                                         });
                                       },
                                     ),
                                    const SizedBox(height: 12),

                                     // LinkedIn
                                     _buildSocialMediaField(
                                       controller: _linkedinController,
                                       label: 'contacts.linkedinLink'.tr(),
                                       icon: Icons.business,
                                       color: Colors.blue,
                                       onClear: () {
                                         setState(() {
                                           _linkedinController.clear();
                                         });
                                       },
                                     ),
                                    const SizedBox(height: 12),

                                     // TikTok
                                     _buildSocialMediaField(
                                       controller: _tiktokController,
                                       label: 'contacts.tiktokLink'.tr(),
                                       icon: Icons.music_note,
                                       color: Colors.black,
                                       onClear: () {
                                         setState(() {
                                           _tiktokController.clear();
                                         });
                                       },
                                     ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('contacts.cancel'.tr()),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Additional validation for phone numbers
                                bool hasInvalidPhone = false;
                                for (int i = 0; i < _phoneNumbers.length; i++) {
                                  final phone = _phoneNumbers[i]['number'] ?? '';
                                  if (phone.isNotEmpty) {
                                    final cleanValue = phone.replaceAll(RegExp(r'[^\d]'), '');
                                    if (cleanValue.length != 9 || !cleanValue.startsWith('9')) {
                                      hasInvalidPhone = true;
                                      break;
                                    }
                                  }
                                }
                                
                                if (hasInvalidPhone) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('validation.phoneInvalid'.tr()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                
                                // Build phone numbers map
                                Map<String, String> phoneNumbers = {};
                                for (int i = 0; i < _phoneNumbers.length; i++) {
                                  phoneNumbers['phone${i + 1}'] =
                                      _phoneNumbers[i]['number'] ?? '';
                                }

                                final updatedContact = {
                                  'name': _nameController.text,
                                  'description': _descriptionController.text,
                                  'rating': _ratingController.text,
                                  'email': _emailController.text,
                                  'website': _websiteController.text,
                                  ...phoneNumbers,
                                  'twitter_link': _twitterController.text,
                                  'telegram_link': _telegramController.text,
                                  'facebook_link': _facebookController.text,
                                  'youtube_link': _youtubeController.text,
                                  'bluesky_link': _blueskyController.text,
                                  'instagram_link': _instagramController.text,
                                  'linkedin_link': _linkedinController.text,
                                  'tiktok_link': _tiktokController.text,
                                };
                                widget.onSave(updatedContact);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('contacts.saveChanges'.tr()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
   }

   Widget _buildSocialMediaField({
     required TextEditingController controller,
     required String label,
     required IconData icon,
     required Color color,
     required VoidCallback onClear,
   }) {
     return Container(
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.grey.shade300),
         color: Colors.white,
       ),
       child: Row(
         children: [
           // Icon and TextField
           Expanded(
             child: TextFormField(
               controller: controller,
               decoration: InputDecoration(
                 labelText: label,
                 border: InputBorder.none,
                 contentPadding: const EdgeInsets.symmetric(
                   horizontal: 16,
                   vertical: 16,
                 ),
                 prefixIcon: Icon(icon, color: color, size: 20),
               ),
               onChanged: (value) {
                 setState(() {}); // Trigger rebuild to show/hide delete button
               },
             ),
           ),
           // Clear/Delete Button - Reactive to text changes
           ValueListenableBuilder<TextEditingValue>(
             valueListenable: controller,
             builder: (context, value, child) {
               if (value.text.isNotEmpty) {
                 return Container(
                   margin: const EdgeInsets.only(right: 8),
                   child: Material(
                     color: Colors.transparent,
                     child: InkWell(
                       onTap: onClear,
                       borderRadius: BorderRadius.circular(20),
                       child: Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: Colors.red.shade50,
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(
                             color: Colors.red.shade200,
                             width: 1,
                           ),
                         ),
                         child: Icon(
                           Icons.clear,
                           size: 16,
                           color: Colors.red.shade600,
                         ),
                       ),
                     ),
                   ),
                 );
               }
               return const SizedBox.shrink();
             },
           ),
         ],
       ),
     );
   }
 }
 
 // Custom input formatter for Ethiopian phone numbers
class EthiopianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // If the first digit is not 9, don't allow it
    if (newText.isNotEmpty && !newText.startsWith('9')) {
      return oldValue;
    }
    
    // Limit to 9 digits
    if (newText.length > 9) {
      newText = newText.substring(0, 9);
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
