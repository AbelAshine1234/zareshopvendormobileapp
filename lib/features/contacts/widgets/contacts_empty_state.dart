import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';

class ContactsEmptyState extends StatelessWidget {
  final VoidCallback onAddContact;

  const ContactsEmptyState({
    super.key,
    required this.onAddContact,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
