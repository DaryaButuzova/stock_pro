part of 'admin_goods_cubit.dart';

sealed class AdminGoodsState extends Equatable {
  const AdminGoodsState();

  @override
  List<Object?> get props => [];
}

final class AdminGoodsInitial extends AdminGoodsState {
  const AdminGoodsInitial();
}

final class AdminGoodsLoading extends AdminGoodsState {
  const AdminGoodsLoading();
}

final class AdminGoodsLoaded extends AdminGoodsState {
  const AdminGoodsLoaded({required this.items});

  final List<Goods> items;

  @override
  List<Object?> get props => [items];
}

final class AdminGoodsFailure extends AdminGoodsState {
  const AdminGoodsFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
