import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction_model.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(const WalletInitial()) {
    on<LoadWalletData>(_onLoadWalletData);
    on<RefreshWalletData>(_onRefreshWalletData);
    on<RequestWithdrawal>(_onRequestWithdrawal);
  }

  Future<void> _onLoadWalletData(
    LoadWalletData event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final walletData = _getMockWalletData();
      emit(WalletLoaded(walletData: walletData));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onRefreshWalletData(
    RefreshWalletData event,
    Emitter<WalletState> emit,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final walletData = _getMockWalletData();
      emit(WalletLoaded(walletData: walletData));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onRequestWithdrawal(
    RequestWithdrawal event,
    Emitter<WalletState> emit,
  ) async {
    if (state is WalletLoaded) {
      final currentWallet = (state as WalletLoaded).walletData;
      
      if (event.amount > currentWallet.balance) {
        emit(const WalletError('Insufficient balance'));
        emit(WalletLoaded(walletData: currentWallet));
        return;
      }

      await Future.delayed(const Duration(seconds: 1));

      final newTransaction = Transaction(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.withdrawal,
        amount: event.amount,
        description: 'Withdrawal to bank account',
        createdAt: DateTime.now(),
      );

      final updatedWallet = WalletData(
        balance: currentWallet.balance - event.amount,
        totalEarnings: currentWallet.totalEarnings,
        totalWithdrawals: currentWallet.totalWithdrawals + event.amount,
        recentTransactions: [newTransaction, ...currentWallet.recentTransactions],
      );

      emit(WithdrawalSuccess(
        message: 'Withdrawal request submitted successfully',
        walletData: updatedWallet,
      ));
      emit(WalletLoaded(walletData: updatedWallet));
    }
  }

  WalletData _getMockWalletData() {
    return WalletData(
      balance: 45750.00,
      totalEarnings: 325000.00,
      totalWithdrawals: 279250.00,
      recentTransactions: [
        Transaction(
          id: 'TXN001',
          type: TransactionType.sale,
          amount: 3000.00,
          description: 'Order #ORD001 - Traditional Coffee Set',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          orderId: 'ORD001',
        ),
        Transaction(
          id: 'TXN002',
          type: TransactionType.sale,
          amount: 1250.00,
          description: 'Order #ORD002 - Ethiopian Spice Mix',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          orderId: 'ORD002',
        ),
        Transaction(
          id: 'TXN003',
          type: TransactionType.withdrawal,
          amount: 50000.00,
          description: 'Withdrawal to bank account',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Transaction(
          id: 'TXN004',
          type: TransactionType.sale,
          amount: 2500.00,
          description: 'Order #ORD003 - Handwoven Basket',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          orderId: 'ORD003',
        ),
        Transaction(
          id: 'TXN005',
          type: TransactionType.refund,
          amount: 800.00,
          description: 'Refund for Order #ORD015',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          orderId: 'ORD015',
        ),
      ],
    );
  }
}
