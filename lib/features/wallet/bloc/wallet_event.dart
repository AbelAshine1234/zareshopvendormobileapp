import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletData extends WalletEvent {
  const LoadWalletData();
}

class RefreshWalletData extends WalletEvent {
  const RefreshWalletData();
}

class RequestWithdrawal extends WalletEvent {
  final double amount;

  const RequestWithdrawal(this.amount);

  @override
  List<Object?> get props => [amount];
}
