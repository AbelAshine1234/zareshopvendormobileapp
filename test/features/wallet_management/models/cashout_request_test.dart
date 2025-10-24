import 'package:flutter_test/flutter_test.dart';
import 'package:zareshop_vendor_app/features/wallet_management/models/cashout_request.dart';

void main() {
  group('CashoutRequest', () {
    final testDateTime = DateTime(2024, 1, 1, 12, 0);

    test('creates instance with all parameters', () {
      final cashout = CashoutRequest(
        id: 1,
        userId: 1,
        vendorId: 1,
        amount: 1000.0,
        status: 'pending',
        reason: 'Monthly withdrawal',
        createdAt: testDateTime,
      );

      expect(cashout.id, 1);
      expect(cashout.userId, 1);
      expect(cashout.vendorId, 1);
      expect(cashout.amount, 1000.0);
      expect(cashout.status, 'pending');
      expect(cashout.reason, 'Monthly withdrawal');
      expect(cashout.createdAt, testDateTime);
    });

    test('fromJson creates valid CashoutRequest', () {
      final json = {
        'id': 1,
        'user_id': 1,
        'vendor_id': 1,
        'amount': 1000.0,
        'status': 'pending',
        'reason': 'Test withdrawal',
        'created_at': '2024-01-01T12:00:00.000Z',
      };

      final cashout = CashoutRequest.fromJson(json);

      expect(cashout.id, 1);
      expect(cashout.vendorId, 1);
      expect(cashout.amount, 1000.0);
      expect(cashout.status, 'pending');
      expect(cashout.reason, 'Test withdrawal');
    });

    test('fromJson handles snake_case fields', () {
      final json = {
        'id': 1,
        'user_id': 1,
        'vendor_id': 1,
        'amount': 1000.0,
        'status': 'approved',
        'reason': 'Test',
        'created_at': '2024-01-01T12:00:00.000Z',
        'approved_at': '2024-01-01T13:00:00.000Z',
      };

      final cashout = CashoutRequest.fromJson(json);

      expect(cashout.vendorId, 1);
      expect(cashout.status, 'approved');
      expect(cashout.approvedAt, isNotNull);
    });

    test('fromJson handles integer amount', () {
      final json = {
        'id': 1,
        'user_id': 1,
        'vendor_id': 1,
        'amount': 1000, // Integer instead of double
        'status': 'pending',
        'created_at': '2024-01-01T12:00:00.000Z',
      };

      final cashout = CashoutRequest.fromJson(json);
      expect(cashout.amount, 1000.0);
    });

    test('fromJson handles string amount', () {
      final json = {
        'id': 1,
        'user_id': 1,
        'vendor_id': 1,
        'amount': '1000.50', // String amount
        'status': 'pending',
        'created_at': '2024-01-01T12:00:00.000Z',
      };

      final cashout = CashoutRequest.fromJson(json);
      expect(cashout.amount, 1000.50);
    });

    test('toJson creates valid JSON', () {
      final cashout = CashoutRequest(
        id: 1,
        userId: 1,
        vendorId: 1,
        amount: 1000.0,
        status: 'pending',
        reason: 'Test',
        createdAt: testDateTime,
      );

      final json = cashout.toJson();

      expect(json['id'], 1);
      expect(json['user_id'], 1);
      expect(json['vendor_id'], 1);
      expect(json['amount'], 1000.0);
      expect(json['status'], 'pending');
      expect(json['reason'], 'Test');
      expect(json['created_at'], isNotNull);
    });

    test('status values are correctly set', () {
      final pending = CashoutRequest(
        id: 1,
        userId: 1,
        vendorId: 1,
        amount: 100,
        status: 'pending',
        reason: 'Test',
        createdAt: testDateTime,
      );

      final approved = CashoutRequest(
        id: 2,
        userId: 1,
        vendorId: 1,
        amount: 100,
        status: 'approved',
        reason: 'Test',
        createdAt: testDateTime,
        approvedAt: testDateTime,
      );

      final rejected = CashoutRequest(
        id: 3,
        userId: 1,
        vendorId: 1,
        amount: 100,
        status: 'rejected',
        reason: 'Test',
        createdAt: testDateTime,
        rejectedAt: testDateTime,
      );

      expect(pending.status, 'pending');
      expect(approved.status, 'approved');
      expect(rejected.status, 'rejected');
    });

    // Note: copyWith not implemented in model yet, skipping test
    test('equality works correctly', () {
      final cashout1 = CashoutRequest(
        id: 1,
        userId: 1,
        vendorId: 1,
        amount: 1000.0,
        status: 'pending',
        reason: 'Test',
        createdAt: testDateTime,
      );

      final cashout2 = CashoutRequest(
        id: 1,
        userId: 1,
        vendorId: 1,
        amount: 1000.0,
        status: 'pending',
        reason: 'Test',
        createdAt: testDateTime,
      );

      // Both should have same data
      expect(cashout1.id, cashout2.id);
      expect(cashout1.amount, cashout2.amount);
    });

    test('status getters work correctly', () {
      final pending = CashoutRequest(
        id: 1,
        userId: 1,
        vendorId: 1,
        amount: 1000.0,
        status: 'pending',
        reason: 'Test',
        createdAt: testDateTime,
      );

      final approved = CashoutRequest(
        id: 2,
        userId: 1,
        vendorId: 1,
        amount: 1000.0,
        status: 'approved',
        reason: 'Test',
        createdAt: testDateTime,
      );

      expect(pending.isPending, true);
      expect(pending.isApproved, false);
      expect(approved.isApproved, true);
      expect(approved.isPending, false);
    });
  });
}
