import 'package:equatable/equatable.dart';
import '../../../data/models/transaction_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final WalletData walletData;

  const WalletLoaded({required this.walletData});

  WalletLoaded copyWith({WalletData? walletData}) {
    return WalletLoaded(walletData: walletData ?? this.walletData);
  }

  @override
  List<Object?> get props => [walletData];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class WithdrawalSuccess extends WalletState {
  final String message;
  final WalletData walletData;

  const WithdrawalSuccess({
    required this.message,
    required this.walletData,
  });

  @override
  List<Object?> get props => [message, walletData];
}
