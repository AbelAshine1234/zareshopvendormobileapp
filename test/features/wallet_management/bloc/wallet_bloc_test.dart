import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zareshop_vendor_app/features/wallet_management/bloc/wallet_bloc.dart';
import 'package:zareshop_vendor_app/features/wallet_management/bloc/wallet_event.dart';
import 'package:zareshop_vendor_app/features/wallet_management/bloc/wallet_state.dart';
import 'package:zareshop_vendor_app/features/wallet_management/models/wallet_data.dart';
import 'package:zareshop_vendor_app/features/wallet_management/models/cashout_request.dart';
import 'package:zareshop_vendor_app/core/bloc/socket_bloc.dart';
import 'package:zareshop_vendor_app/core/services/api_service.dart';

// Mocks
class MockSocketBloc extends Mock implements SocketBloc {}
class MockApiService extends Mock implements ApiService {}

void main() {
  group('WalletBloc', () {
    late WalletBloc walletBloc;
    late MockSocketBloc mockSocketBloc;

    setUp(() {
      mockSocketBloc = MockSocketBloc();
      walletBloc = WalletBloc(socketBloc: mockSocketBloc);
    });

    tearDown(() {
      walletBloc.close();
    });

    test('initial state is WalletInitial', () {
      expect(walletBloc.state, equals(WalletInitial()));
    });

    group('FetchWalletBalance', () {
      final mockWalletData = WalletData(
        id: 1,
        vendorId: 1,
        balance: 1000.0,
        currency: 'Br',
        transactions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockCashoutRequests = [
        CashoutRequest(
          id: 1,
          vendorId: 1,
          amount: 100.0,
          status: 'pending',
          reason: 'Test cashout',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      blocTest<WalletBloc, WalletState>(
        'emits [WalletLoading, WalletBalanceLoadedWithCashouts] when FetchWalletBalance is successful',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const FetchWalletBalance()),
        expect: () => [
          isA<WalletLoading>(),
          isA<WalletBalanceLoadedWithCashouts>()
            .having((s) => s.walletData.balance, 'balance', greaterThan(0)),
        ],
      );

      blocTest<WalletBloc, WalletState>(
        'emits [WalletLoading, WalletError] when FetchWalletBalance fails',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const FetchWalletBalance()),
        expect: () => [
          isA<WalletLoading>(),
          isA<WalletError>(),
        ],
      );
    });

    group('CreateCashoutRequest', () {
      const testAmount = 500.0;
      const testReason = 'Test withdrawal';
      const testVendorId = '1';

      blocTest<WalletBloc, WalletState>(
        'emits [WalletLoading, CashoutRequestCreated] when cashout request is successful',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const CreateCashoutRequest(
          amount: testAmount,
          reason: testReason,
          vendorId: testVendorId,
        )),
        expect: () => [
          isA<WalletLoading>()
            .having((s) => s.message, 'message', contains('Creating')),
          isA<CashoutRequestCreated>()
            .having((s) => s.message, 'message', contains('successfully')),
        ],
      );

      blocTest<WalletBloc, WalletState>(
        'emits [WalletLoading, CashoutRequestError] when cashout request fails',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const CreateCashoutRequest(
          amount: testAmount,
          reason: testReason,
          vendorId: testVendorId,
        )),
        expect: () => [
          isA<WalletLoading>(),
          isA<CashoutRequestError>(),
        ],
      );
    });

    group('RefreshWalletBalance', () {
      blocTest<WalletBloc, WalletState>(
        'emits [WalletBalanceLoadedWithCashouts] without loading state',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const RefreshWalletBalance()),
        expect: () => [
          isA<WalletBalanceLoadedWithCashouts>(),
        ],
      );
    });

    group('WebSocket Events', () {
      blocTest<WalletBloc, WalletState>(
        'handles OnWalletFundsAdded event and refreshes balance',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const OnWalletFundsAdded(
          walletId: 1,
          vendorId: 1,
          amount: 100.0,
          newBalance: 1100.0,
          reason: 'Admin added funds',
        )),
        expect: () => [
          isA<WalletFundsAddedReceived>()
            .having((s) => s.amount, 'amount', 100.0)
            .having((s) => s.newBalance, 'newBalance', 1100.0),
          isA<WalletBalanceLoadedWithCashouts>(),
        ],
      );

      blocTest<WalletBloc, WalletState>(
        'handles OnWalletFundsDeducted event and refreshes balance',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const OnWalletFundsDeducted(
          walletId: 1,
          vendorId: 1,
          amount: 50.0,
          newBalance: 950.0,
          reason: 'Admin deducted funds',
        )),
        expect: () => [
          isA<WalletFundsDeductedReceived>()
            .having((s) => s.amount, 'amount', 50.0)
            .having((s) => s.newBalance, 'newBalance', 950.0),
          isA<WalletBalanceLoadedWithCashouts>(),
        ],
      );

      blocTest<WalletBloc, WalletState>(
        'handles OnCashoutRequestStatusChanged for approved status',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const OnCashoutRequestStatusChanged(
          requestId: 1,
          vendorId: 1,
          status: 'approved',
          newBalance: 900.0,
          reason: null,
        )),
        expect: () => [
          isA<CashoutStatusUpdated>()
            .having((s) => s.status, 'status', 'approved')
            .having((s) => s.message, 'message', contains('approved')),
          isA<WalletBalanceLoadedWithCashouts>(),
        ],
      );

      blocTest<WalletBloc, WalletState>(
        'handles OnCashoutRequestStatusChanged for rejected status',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const OnCashoutRequestStatusChanged(
          requestId: 1,
          vendorId: 1,
          status: 'rejected',
          reason: 'Insufficient verification',
        )),
        expect: () => [
          isA<CashoutStatusUpdated>()
            .having((s) => s.status, 'status', 'rejected')
            .having((s) => s.message, 'message', contains('rejected'))
            .having((s) => s.message, 'message', contains('Insufficient verification')),
          isA<WalletBalanceLoadedWithCashouts>(),
        ],
      );
    });

    group('FetchCashoutRequests', () {
      blocTest<WalletBloc, WalletState>(
        'emits [WalletLoading, CashoutRequestsLoaded] when successful',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const FetchCashoutRequests()),
        expect: () => [
          isA<WalletLoading>(),
          isA<CashoutRequestsLoaded>()
            .having((s) => s.requests, 'requests', isNotEmpty),
        ],
      );
    });

    group('FetchTransactionHistory', () {
      blocTest<WalletBloc, WalletState>(
        'emits [TransactionLoading, TransactionHistoryLoaded] when successful',
        build: () => walletBloc,
        act: (bloc) => bloc.add(const FetchTransactionHistory()),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionHistoryLoaded>()
            .having((s) => s.transactions, 'transactions', isList),
        ],
      );
    });
  });

  group('WalletState', () {
    test('WalletBalanceLoadedWithCashouts extends WalletBalanceLoaded', () {
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

      expect(state, isA<WalletBalanceLoaded>());
      expect(state.cashoutRequests, isEmpty);
    });

    test('WalletBalanceLoadedWithCashouts props include cashoutRequests', () {
      final walletData = WalletData(
        id: 1,
        vendorId: 1,
        balance: 1000.0,
        currency: 'Br',
        transactions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final cashout = CashoutRequest(
        id: 1,
        vendorId: 1,
        amount: 100.0,
        status: 'pending',
        reason: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = WalletBalanceLoadedWithCashouts(
        walletData: walletData,
        cashoutRequests: [cashout],
      );

      expect(state.props, contains(state.cashoutRequests));
    });
  });

  group('WalletEvent', () {
    test('CreateCashoutRequest with all parameters', () {
      const event = CreateCashoutRequest(
        amount: 500.0,
        reason: 'Monthly withdrawal',
        vendorId: '1',
      );

      expect(event.amount, 500.0);
      expect(event.reason, 'Monthly withdrawal');
      expect(event.vendorId, '1');
    });

    test('CreateCashoutRequest props are correct', () {
      const event = CreateCashoutRequest(
        amount: 500.0,
        reason: 'Test',
        vendorId: '1',
      );

      expect(event.props, [500.0, 'Test', '1']);
    });

    test('OnCashoutRequestStatusChanged props include newBalance', () {
      const event = OnCashoutRequestStatusChanged(
        requestId: 1,
        vendorId: 1,
        status: 'approved',
        newBalance: 900.0,
        reason: null,
      );

      expect(event.props, contains(900.0));
    });
  });
}
