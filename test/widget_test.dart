import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zareshop_vendor_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZareshopVendorApp());

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
