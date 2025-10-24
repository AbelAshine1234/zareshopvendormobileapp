import 'package:flutter_test/flutter_test.dart';
import 'package:zareshop_vendor_app/core/models/socket_event.dart';

void main() {
  group('CashoutRequestEvent', () {
    test('fromJson creates valid event with all fields', () {
      final json = {
        'requestId': 1,
        'vendorId': 1,
        'amount': 1000.0,
        'status': 'approved',
        'reason': 'Test withdrawal',
        'timestamp': '2024-01-01T12:00:00.000Z',
      };

      final event = CashoutRequestEvent.fromJson(json);

      expect(event.requestId, 1);
      expect(event.vendorId, 1);
      expect(event.amount, 1000.0);
      expect(event.status, 'approved');
      expect(event.reason, 'Test withdrawal');
      expect(event.timestamp, isNotNull);
    });

    test('fromJson handles snake_case fields', () {
      final json = {
        'request_id': 2,
        'vendor_id': 2,
        'amount': 500.0,
        'status': 'pending',
        'timestamp': '2024-01-01T12:00:00.000Z',
      };

      final event = CashoutRequestEvent.fromJson(json);

      expect(event.requestId, 2);
      expect(event.vendorId, 2);
    });

    test('fromJson handles integer amount', () {
      final json = {
        'requestId': 1,
        'vendorId': 1,
        'amount': 1000,
        'status': 'pending',
      };

      final event = CashoutRequestEvent.fromJson(json);
      expect(event.amount, 1000.0);
    });

    test('fromJson handles string amount', () {
      final json = {
        'requestId': 1,
        'vendorId': 1,
        'amount': '1500.50',
        'status': 'pending',
      };

      final event = CashoutRequestEvent.fromJson(json);
      expect(event.amount, 1500.50);
    });

    test('fromJson handles string IDs', () {
      final json = {
        'requestId': '10',
        'vendorId': '20',
        'amount': 1000.0,
        'status': 'approved',
      };

      final event = CashoutRequestEvent.fromJson(json);
      expect(event.requestId, 10);
      expect(event.vendorId, 20);
    });

    test('fromJson handles extra fields from backend', () {
      final json = {
        'requestId': 1,
        'userId': 7, // Extra field
        'vendorId': 1,
        'amount': 1000.0,
        'newBalance': 5000.0, // Extra field
        'transactionId': 'txn_123', // Extra field
        'status': 'approved',
        'message': 'Approved by admin', // Extra field
        'timestamp': '2024-01-01T12:00:00.000Z',
      };

      // Should not throw error
      final event = CashoutRequestEvent.fromJson(json);
      expect(event.requestId, 1);
      expect(event.amount, 1000.0);
      expect(event.status, 'approved');
    });

    test('fromJson defaults status to pending when null', () {
      final json = {
        'requestId': 1,
        'vendorId': 1,
        'amount': 1000.0,
      };

      final event = CashoutRequestEvent.fromJson(json);
      expect(event.status, 'pending');
    });

    test('fromJson defaults timestamp to now when null', () {
      final json = {
        'requestId': 1,
        'vendorId': 1,
        'amount': 1000.0,
        'status': 'pending',
      };

      final before = DateTime.now();
      final event = CashoutRequestEvent.fromJson(json);
      final after = DateTime.now();

      expect(event.timestamp, isNotNull);
      expect(event.timestamp!.isAfter(before) || event.timestamp!.isAtSameMomentAs(before), true);
      expect(event.timestamp!.isBefore(after) || event.timestamp!.isAtSameMomentAs(after), true);
    });

    test('fromJson throws error when json is null', () {
      expect(
        () => CashoutRequestEvent.fromJson(null),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('toJson creates valid JSON', () {
      final event = CashoutRequestEvent(
        requestId: 1,
        vendorId: 1,
        amount: 1000.0,
        status: 'approved',
        reason: 'Test',
        timestamp: DateTime(2024, 1, 1, 12, 0),
      );

      final json = event.toJson();

      expect(json['request_id'], 1);
      expect(json['vendor_id'], 1);
      expect(json['amount'], 1000.0);
      expect(json['status'], 'approved');
      expect(json['reason'], 'Test');
      expect(json['timestamp'], isNotNull);
    });
  });

  group('WalletFundsAddedEvent', () {
    test('fromJson creates valid event', () {
      final json = {
        'walletId': 1,
        'vendorId': 1,
        'amount': 500.0,
        'newBalance': 1500.0,
        'reason': 'Admin added funds',
        'timestamp': '2024-01-01T12:00:00.000Z',
      };

      final event = WalletFundsAddedEvent.fromJson(json);

      expect(event.walletId, 1);
      expect(event.vendorId, 1);
      expect(event.amount, 500.0);
      expect(event.newBalance, 1500.0);
      expect(event.reason, 'Admin added funds');
    });

    test('fromJson handles snake_case fields', () {
      final json = {
        'wallet_id': 2,
        'vendor_id': 2,
        'amount': 300.0,
        'new_balance': 1300.0,
      };

      final event = WalletFundsAddedEvent.fromJson(json);

      expect(event.walletId, 2);
      expect(event.vendorId, 2);
      expect(event.newBalance, 1300.0);
    });

    test('fromJson handles integer values', () {
      final json = {
        'walletId': 1,
        'vendorId': 1,
        'amount': 500,
        'newBalance': 1500,
      };

      final event = WalletFundsAddedEvent.fromJson(json);

      expect(event.amount, 500.0);
      expect(event.newBalance, 1500.0);
    });

    test('toJson creates valid JSON', () {
      final event = WalletFundsAddedEvent(
        walletId: 1,
        vendorId: 1,
        amount: 500.0,
        newBalance: 1500.0,
        reason: 'Test',
        timestamp: DateTime(2024, 1, 1),
      );

      final json = event.toJson();

      expect(json['wallet_id'], 1);
      expect(json['vendor_id'], 1);
      expect(json['amount'], 500.0);
      expect(json['new_balance'], 1500.0);
    });
  });

  group('WalletFundsDeductedEvent', () {
    test('fromJson creates valid event', () {
      final json = {
        'walletId': 1,
        'vendorId': 1,
        'amount': 200.0,
        'newBalance': 800.0,
        'reason': 'Cashout approved',
        'timestamp': '2024-01-01T12:00:00.000Z',
      };

      final event = WalletFundsDeductedEvent.fromJson(json);

      expect(event.walletId, 1);
      expect(event.vendorId, 1);
      expect(event.amount, 200.0);
      expect(event.newBalance, 800.0);
      expect(event.reason, 'Cashout approved');
    });

    test('fromJson handles snake_case fields', () {
      final json = {
        'wallet_id': 3,
        'vendor_id': 3,
        'amount': 100.0,
        'new_balance': 900.0,
      };

      final event = WalletFundsDeductedEvent.fromJson(json);

      expect(event.walletId, 3);
      expect(event.vendorId, 3);
      expect(event.newBalance, 900.0);
    });

    test('toJson creates valid JSON', () {
      final event = WalletFundsDeductedEvent(
        walletId: 1,
        vendorId: 1,
        amount: 200.0,
        newBalance: 800.0,
        reason: 'Test',
        timestamp: DateTime(2024, 1, 1),
      );

      final json = event.toJson();

      expect(json['wallet_id'], 1);
      expect(json['amount'], 200.0);
      expect(json['new_balance'], 800.0);
    });
  });
}
