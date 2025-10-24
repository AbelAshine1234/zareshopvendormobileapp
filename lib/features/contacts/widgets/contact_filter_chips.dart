import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';

class ContactFilterChips extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const ContactFilterChips({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

 
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
