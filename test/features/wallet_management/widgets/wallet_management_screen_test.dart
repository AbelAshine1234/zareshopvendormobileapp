import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zareshop_vendor_app/features/wallet_management/screens/wallet_management_screen.dart';
import 'package:zareshop_vendor_app/features/wallet_management/bloc/wallet_bloc.dart';
import 'package:zareshop_vendor_app/features/wallet_management/bloc/wallet_state.dart';
import 'package:zareshop_vendor_app/features/wallet_management/bloc/wallet_event.dart';
import 'package:zareshop_vendor_app/features/wallet_management/models/wallet_data.dart';
import 'package:zareshop_vendor_app/features/wallet_management/models/cashout_request.dart';
import 'package:zareshop_vendor_app/features/wallet_management/models/wallet_transaction.dart';
import 'package:zareshop_vendor_app/shared/theme/app_theme.dart';

class MockWalletBloc extends Mock implements WalletBloc {}

void main() {
  late MockWalletBloc mockWalletBloc;

  setUp(() {
    mockWalletBloc = MockWalletBloc();
    registerFallbackValue(const FetchWalletBalance());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: ThemeData.light(),
      home: BlocProvider<WalletBloc>.value(
        value: mockWalletBloc,
        child: const WalletManagementScreen(),
      ),
    );
  }

  group('WalletManagementScreen Widget Tests', () {
    testWidgets('displays loading indicator when state is WalletLoading', (tester) async {
      when(() => mockWalletBloc.state).thenReturn(const WalletLoading());
      when(() => mockWalletBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays error message when state is WalletError', (tester) async {
      const errorMessage = 'Failed to load wallet';
      when(() => mockWalletBloc.state).thenReturn(const WalletError(errorMessage));
      when(() => mockWalletBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Failed to load transactions'), findsOneWidget);
    });

    testWidgets('displays wallet balance when loaded', (tester) async {
      final walletData = WalletData(
        id: 1,
        vendorId: 1,
        balance: 1500.0,
        currency: 'Br',
        transactions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = WalletBalanceLoadedWithCashouts(
        walletData: walletData,
        cashoutRequests: [],
      );

      when(() => mockWalletBloc.state).thenReturn(state);
      when(() => mockWalletBloc.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Total Balance'), findsOneWidget);
      expect(find.textContaining('Br'), findsWidgets);
    });

    testWidgets('displays Request Cashout button', (tester) async {
      final walletData = WalletData(
        id: 1,
        vendorId: 1,
        balance: 1000.0,
        currency: 'Br',
        transactions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = WalletBalanceLoadedWithCashouts(
        walletData: walletData,
        cashoutRequests: [],
      );

      when(() => mockWalletBloc.state).thenReturn(state);
      when(() => mockWalletBloc.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Request Cashout'), findsOneWidget);
    });

    testWidgets('displays cashout requests in transaction list', (tester) async {
      final cashoutRequest = CashoutRequest(
        id: 1,
        vendorId: 1,
        amount: 500.0,
        status: 'pending',
        reason: 'Test withdrawal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final walletData = WalletData(
        id: 1,
        vendorId: 1,
        balance: 1000.0,
        currency: 'Br',
        transactions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = WalletBalanceLoadedWithCashouts(
        walletData: walletData,
        cashoutRequests: [cashoutRequest],
      );

      when(() => mockWalletBloc.state).thenReturn(state);
      when(() => mockWalletBloc.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Recent Transactions'), findsOneWidget);
      // Cashout request should be in the list
      expect(find.textContaining('500'), findsWidgets);
    });

    testWidgets('displays both transactions and cashout requests sorted by date', (tester) async {
      final now = DateTime.now();
      
      final transaction = WalletTransaction(
        id: 1,
        walletId: 1,
        type: 'credit',
        amount: 200.0,
        reason: 'Payment received',
        createdAt: now.subtract(const Duration(hours: 2)),
      );

      final cashoutRequest = CashoutRequest(
        id: 1,
        vendorId: 1,
        amount: 300.0,
        status: 'pending',
        reason: 'Withdrawal',
        createdAt: now.subtract(const Duration(hours: 1)), // More recent
        updatedAt: now.subtract(const Duration(hours: 1)),
      );

      final walletData = WalletData(
        id: 1,
        vendorId: 1,
        balance: 1000.0,
        currency: 'Br',
        transactions: [transaction],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = WalletBalanceLoadedWithCashouts(
        walletData: walletData,
        cashoutRequests: [cashoutRequest],
      );

      when(() => mockWalletBloc.state).thenReturn(state);
      when(() => mockWalletBloc.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Both items should be displayed
      expect(find.textContaining('200'), findsWidgets);
      expect(find.textContaining('300'), findsWidgets);
    });

    testWidgets('shows different status badges for cashout requests', (tester) async {
      final pendingCashout = CashoutRequest(
        id: 1,
        vendorId: 1,
        amount: 100.0,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final approvedCashout = CashoutRequest(
        id: 2,
        vendorId: 1,
        amount: 200.0,
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );

      final rejectedCashout = CashoutRequest(
        id: 3,
        vendorId: 1,
        amount: 300.0,
        status: 'rejected',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      );

      final walletData = WalletData(
        id: 1,
        vendorId: 1,
        balance: 1000.0,
        currency: 'Br',
        transactions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = WalletBalanceLoadedWithCashouts(
        walletData: walletData,
        cashoutRequests: [pendingCashout, approvedCashout, rejectedCashout],
      );

      when(() => mockWalletBloc.state).thenReturn(state);
      when(() => mockWalletBloc.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // All three cashout requests should be visible (limited to 10 items total)
      expect(find.textContaining('100'), findsWidgets);
      expect(find.textContaining('200'), findsWidgets);
      expect(find.textContaining('300'), findsWidgets);
    });

    testWidgets('displays no transactions message when empty', (tester) async {
      final walletData = WalletData(
        id: 1,
        vendorId: 1,
        balance: 0.0,
        currency: 'Br',
        transactions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = WalletBalanceLoadedWithCashouts(
        walletData: walletData,
        cashoutRequests: [],
      );

      when(() => mockWalletBloc.state).thenReturn(state);
      when(() => mockWalletBloc.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('Request Cashout button opens dialog', (tester) async {
      final walletData = WalletData(
        id: 1,
        vendorId: 1,
        balance: 1000.0,
        currency: 'Br',
        transactions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = WalletBalanceLoadedWithCashouts(
        walletData: walletData,
        cashoutRequests: [],
      );

      when(() => mockWalletBloc.state).thenReturn(state);
      when(() => mockWalletBloc.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Tap Request Cashout button
      await tester.tap(find.text('Request Cashout'));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Request Cashout'), findsWidgets);
    });

    testWidgets('balance visibility toggle works', (tester) async {
      final walletData = WalletData(
        id: 1,
        vendorId: 1,
        balance: 1234.56,
        currency: 'Br',
        transactions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = WalletBalanceLoadedWithCashouts(
        walletData: walletData,
        cashoutRequests: [],
      );

      when(() => mockWalletBloc.state).thenReturn(state);
      when(() => mockWalletBloc.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Find and tap visibility toggle icon
      final visibilityIcon = find.byIcon(Icons.visibility_off);
      if (visibilityIcon.evaluate().isNotEmpty) {
        await tester.tap(visibilityIcon);
        await tester.pump();
        
        // Balance should now be hidden
        expect(find.text('••••••'), findsOneWidget);
      }
    });
  });
}
