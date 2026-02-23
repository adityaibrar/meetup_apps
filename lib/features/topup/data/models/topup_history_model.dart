import '../../domain/entities/topup_history.dart';

class TopUpHistoryModel extends TopUpHistory {
  const TopUpHistoryModel({
    required super.id,
    required super.orderId,
    required super.amount,
    required super.points,
    required super.status,
    required super.paymentType,
    super.paymentInfo,
    required super.createdAt,
  });

  factory TopUpHistoryModel.fromJson(Map<String, dynamic> json) {
    return TopUpHistoryModel(
      id: json['id'],
      orderId: json['order_id'],
      amount: (json['amount'] as num).toDouble(),
      points: json['points'],
      status: json['status'],
      paymentType: json['payment_type'],
      paymentInfo: json['payment_info'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
