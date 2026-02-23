import 'package:equatable/equatable.dart';

class TopUpHistory extends Equatable {
  final int id;
  final String orderId;
  final double amount;
  final int points;
  final String status;
  final String paymentType;
  final String? paymentInfo;
  final DateTime createdAt;

  const TopUpHistory({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.points,
    required this.status,
    required this.paymentType,
    this.paymentInfo,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    amount,
    points,
    status,
    paymentType,
    paymentInfo,
    createdAt,
  ];
}
