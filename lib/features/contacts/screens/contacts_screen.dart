import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/contacts_bloc.dart';
import '../bloc/contacts_event.dart';
import '../bloc/contacts_state.dart';
import '../widgets/contact_card.dart';
import '../widgets/contact_form_dialog.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';



class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    // Load contacts when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsBloc>().add(LoadContacts());
    });
  }

  void _handleContactAction(String action, Map<String, dynamic> contact) {
    // Handle contact actions (call, message, etc.)
    print('Action: $action for contact: ${contact['name']}');
    
    if (action == 'contact') {
      // Show update information dialog
      _showUpdateInformationDialog(contact);
    } else if (action == 'delete') {
      // Show delete confirmation dialog
      _showDeleteConfirmationDialog(contact);
    }
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('contacts.deleteContact'.tr()),
          content: Text('contacts.deleteContactMessage'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('contacts.cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllContacts();
              },
              child: Text('contacts.delete'.tr(), style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllContacts() async {
    try {
      final authBloc = context.read<AuthBloc>();
      final contactsBloc = context.read<ContactsBloc>();
      
      String? token;
      final authState = authBloc.state;
      if (authState is AuthLoginResponse) {
        token = authState.data['token'] as String?;
      }
      
      if (token == null) {
        token = await ApiService.getToken();
      }
      
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      final contactsState = contactsBloc.state;
      if (contactsState is ContactsLoaded) {
        final contacts = contactsState.contacts;
        
        // Delete all contacts
        for (var contact in contacts) {
          final contactId = contact['id'];
          if (contactId != null) {
            await ApiService.deleteVendorContact(
              token: token,
              contactId: contactId,
            );
          }
        }
        
        // Refresh the contacts list
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            contactsBloc.add(LoadContacts());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('contacts.deleteSuccess'.tr()),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Error deleting contacts: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('contacts.deleteError'.tr() + ': ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  void _showUpdateInformationDialog(Map<String, dynamic> contact) async {
    final authBloc = context.read<AuthBloc>();
    final contactsBloc = context.read<ContactsBloc>();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ContactFormDialog(
          contact: contact,
          onSave: (updatedContact) async {
            // Handle the updated contact data
            print('Updated contact: $updatedContact');
            
            // Close the dialog first
            Navigator.of(dialogContext).pop();
            
            try {
              // Get JWT token
              String? token;
              
              final authState = authBloc.state;
              if (authState is AuthLoginResponse) {
                token = authState.data['token'] as String?;
              }
              
              if (token == null) {
                token = await ApiService.getToken();
              }
              
              if (token == null) {
                throw Exception('No authentication token found');
              }
              
              // Get existing contacts from ContactsBloc
              final contactsState = contactsBloc.state;
              final existingContacts = <Map<String, dynamic>>[];
              
              if (contactsState is ContactsLoaded) {
                existingContacts.addAll(contactsState.contacts);
              }
              
              // Prepare contacts to create/update
              List<Map<String, dynamic>> contactsToCreate = [];
              
              // Add phone numbers as contacts
              for (int i = 1; i <= 4; i++) {
                final phoneNumber = updatedContact['phone$i'];
                if (phoneNumber != null && phoneNumber.isNotEmpty) {
                  // Check if this phone already exists
                  bool exists = existingContacts.any((c) => 
                    c['type'] == 'phone' && 
                    c['value']?.toString().replaceAll('+251', '').replaceAll(' ', '') == 
                    phoneNumber.toString().replaceAll(' ', '')
                  );
                  
                  if (!exists) {
                    contactsToCreate.add({
                      'type': 'phone',
                      'label': i == 1 ? 'Primary' : i == 2 ? 'Secondary' : i == 3 ? 'Additional' : 'Emergency',
                      'value': '+251 $phoneNumber',
                      'is_primary': i == 1,
                      'is_verified': false,
                    });
                  }
                }
              }
              
              // Add email as contact if it exists and is new
              if (updatedContact['email'] != null && updatedContact['email'].isNotEmpty) {
                bool emailExists = existingContacts.any((c) => c['type'] == 'email');
                if (!emailExists) {
                  contactsToCreate.add({
                    'type': 'email',
                    'label': 'Email',
                    'value': updatedContact['email'],
                    'is_primary': true,
                    'is_verified': false,
                  });
                }
              }
              
              // Add website as contact if it exists and is new
              if (updatedContact['website'] != null && updatedContact['website'].isNotEmpty) {
                bool websiteExists = existingContacts.any((c) => c['type'] == 'website');
                if (!websiteExists) {
                  contactsToCreate.add({
                    'type': 'website',
                    'label': 'Website',
                    'value': updatedContact['website'],
                    'is_primary': true,
                    'is_verified': false,
                  });
                }
              }
              
              // Add social media links
              final socialMediaFields = [
                {'field': 'twitter_link', 'label': 'Twitter'},
                {'field': 'telegram_link', 'label': 'Telegram'},
                {'field': 'facebook_link', 'label': 'Facebook'},
                {'field': 'youtube_link', 'label': 'YouTube'},
                {'field': 'bluesky_link', 'label': 'Bluesky'},
                {'field': 'instagram_link', 'label': 'Instagram'},
                {'field': 'linkedin_link', 'label': 'LinkedIn'},
                {'field': 'tiktok_link', 'label': 'TikTok'},
              ];
              
              for (var socialMedia in socialMediaFields) {
                final value = updatedContact[socialMedia['field']];
                if (value != null && value.toString().isNotEmpty) {
                  bool exists = existingContacts.any((c) => 
                    c['type'] == 'social_media' && 
                    (c['value']?.toString().toLowerCase().contains(value.toString().toLowerCase()) ?? false)
                  );
                  
                  if (!exists) {
                    contactsToCreate.add({
                      'type': 'social_media',
                      'label': socialMedia['label'],
                      'value': value,
                      'is_primary': false,
                      'is_verified': false,
                    });
                  }
                }
              }
              
              // Create bulk contacts if any
              if (contactsToCreate.isNotEmpty) {
                print('Creating ${contactsToCreate.length} contacts...');
                final result = await ApiService.createVendorContactsBulk(
                  token: token,
                  contacts: contactsToCreate,
                );
                
                if (result['success'] != true) {
                  print('Failed to create contacts: ${result['error']}');
                } else {
                  print('Contacts created successfully');
                }
              }
              
              // Refresh contacts to get updated data immediately
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  contactsBloc.add(LoadContacts());
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Contact information updated successfully'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              });
              
            } catch (e) {
              print('Error saving contact information: $e');
              
              // Show error message
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving contact information: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              });
            }
          },
        );
      },
    );
  }

  Map<String, dynamic> _buildContactFromContacts(ContactsState contactsState) {
    // Default contact data
    Map<String, dynamic> contact = {
      'name': 'Contact Information',
      'description': 'Your business contact details',
      'rating': 'N/A',
      'earned': 'N/A',
    };

    print('📊 [CONTACTS_SCREEN] Building contact from state: ${contactsState.runtimeType}');
    
    // Get contacts from ContactsBloc
    if (contactsState is ContactsLoaded) {
      final contacts = contactsState.contacts;
      final vendor = contactsState.vendor;
      
      // Use vendor data if available
      if (vendor != null) {
        contact['name'] = vendor['name'] ?? 'Contact Information';
        contact['description'] = vendor['description'] ?? 'Your business contact details';
        
        // Get cover image
        final coverImage = vendor['cover_image'];
        if (coverImage != null && coverImage['image_url'] != null) {
          contact['image'] = coverImage['image_url'];
        }
        
        print('📊 [CONTACTS_SCREEN] Vendor name: ${contact['name']}');
        print('📊 [CONTACTS_SCREEN] Vendor description: ${contact['description']}');
      }
      
      print('📊 [CONTACTS_SCREEN] Got ${contacts.length} contacts');
      print('📊 [CONTACTS_SCREEN] Contacts: $contacts');
      
      // Get phone numbers from contacts
      int phoneIndex = 1;
      for (var contactItem in contacts) {
        print('📊 [CONTACTS_SCREEN] Processing contact: $contactItem');
        if (contactItem['type'] == 'phone' && phoneIndex <= 4) {
          // Extract phone number from value field
          String phoneValue = contactItem['value']?.toString() ?? '';
          // Remove country code prefix if present
          if (phoneValue.startsWith('+251')) {
            phoneValue = phoneValue.substring(4);
          }
          contact['phone$phoneIndex'] = phoneValue;
          phoneIndex++;
        }
        
        // Get email
        if (contactItem['type'] == 'email') {
          contact['email'] = contactItem['value'] ?? '';
        }
        
        // Get website
        if (contactItem['type'] == 'website') {
          contact['website'] = contactItem['value'] ?? '';
        }
        
        // Get social media links by label
        String label = (contactItem['label']?.toString().toLowerCase() ?? '');
        String value = contactItem['value']?.toString() ?? '';
        
        if (contactItem['type'] == 'social_media') {
          if (label.contains('twitter') || value.contains('twitter')) {
            contact['twitter_link'] = value;
          } else if (label.contains('telegram') || value.contains('telegram')) {
            contact['telegram_link'] = value;
          } else if (label.contains('facebook') || value.contains('facebook')) {
            contact['facebook_link'] = value;
          } else if (label.contains('youtube') || value.contains('youtube')) {
            contact['youtube_link'] = value;
          } else if (label.contains('bluesky') || value.contains('bluesky')) {
            contact['bluesky_link'] = value;
          } else if (label.contains('instagram') || value.contains('instagram')) {
            contact['instagram_link'] = value;
          } else if (label.contains('linkedin') || value.contains('linkedin')) {
            contact['linkedin_link'] = value;
          } else if (label.contains('tiktok') || value.contains('tiktok')) {
            contact['tiktok_link'] = value;
          }
        }
      }
    }
    
    print('📊 [CONTACTS_SCREEN] Final contact data: $contact');
    print('📊 [CONTACTS_SCREEN] Email: ${contact['email']}');
    print('📊 [CONTACTS_SCREEN] Website: ${contact['website']}');
    print('📊 [CONTACTS_SCREEN] Phone1: ${contact['phone1']}');
    print('📊 [CONTACTS_SCREEN] Phone2: ${contact['phone2']}');

    return contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('contacts.title'.tr()),
        elevation: 0,
        actions: [
          // Theme Selector
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(Icons.palette_outlined),
                tooltip: 'Change Theme',
                onPressed: () => _showThemeSelector(context, themeProvider),
              );
            },
          ),
          // Language Selector
          Consumer<LocalizationService>(
            builder: (context, localization, child) {
              return IconButton(
                icon: Icon(Icons.language),
                tooltip: 'Change Language',
                onPressed: () => _showLanguageSelector(context, localization),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, contactsState) {
          // Show loading state
          if (contactsState is ContactsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          // Show error state
          if (contactsState is ContactsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'contacts.errorLoading'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contactsState.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ContactsBloc>().add(LoadContacts());
                    },
                    child: Text('contacts.retry'.tr()),
                  ),
                ],
              ),
            );
          }
          
          print('📊 [CONTACTS_SCREEN] Current state: ${contactsState.runtimeType}');
          
          final contact = _buildContactFromContacts(contactsState);
          final hasContacts = contactsState is ContactsLoaded && contactsState.contacts.isNotEmpty;
          
          print('📊 [CONTACTS_SCREEN] About to render ContactCard with: $contact');
          print('📊 [CONTACTS_SCREEN] Has contacts: $hasContacts');
          
          if (!hasContacts) {
            // Show empty state with floating action button
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contact_mail_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'contacts.noContactInfo'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'contacts.addContactInfo'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Center(
                child: ContactCard(
                  contact: contact,
                  onAction: _handleContactAction,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, state) {
          // Only show floating button if no contacts exist
          if (state is ContactsLoaded && state.contacts.isNotEmpty) {
            return const SizedBox.shrink(); // Hide the button
          }
          
          return FloatingActionButton.extended(
            onPressed: () {
              // Show add contact dialog (using update dialog with empty contact)
              final contact = _buildContactFromContacts(context.read<ContactsBloc>().state);
              _showUpdateInformationDialog(contact);
            },
            icon: const Icon(Icons.add),
            label: Text('contacts.addContactInfoButton'.tr()),
          );
        },
      ),
    );
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('contacts.selectTheme'.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppThemes.allThemes.map((theme) {
                final themeType = AppThemes.getThemeType(theme);
                final isSelected = themeProvider.isThemeSelected(themeType);
                
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? theme.primary : Colors.grey,
                  ),
                  title: Text('${theme.emoji} ${theme.name}'),
                  subtitle: Text(theme.description),
                  selected: isSelected,
                  onTap: () {
                    themeProvider.setTheme(themeType);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('contacts.close'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context, LocalizationService localization) {
    final currentLanguage = localization.currentLanguage;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('contacts.selectLanguage'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: Text('English'),
                trailing: currentLanguage == 'en' ? Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  await localization.loadLanguage('en');
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              ListTile(
                leading: Text('🇪🇹', style: TextStyle(fontSize: 24)),
                title: Text('አማርኛ'),
                trailing: currentLanguage == 'am' ? Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  await localization.loadLanguage('am');
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              ListTile(
                leading: Text('🇪🇹', style: TextStyle(fontSize: 24)),
                title: Text('Afaan Oromoo'),
                trailing: currentLanguage == 'om' ? Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  await localization.loadLanguage('om');
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('contacts.close'.tr()),
            ),
          ],
        );
      },
    );
  }
}