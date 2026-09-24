import 'json_utils.dart';

class IkaPaymentOverview {
  const IkaPaymentOverview({
    this.instructions = const {},
    this.items = const [],
  });

  final Map<String, dynamic> instructions;
  final List<IkaPaymentItem> items;

  factory IkaPaymentOverview.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaPaymentOverview(
      instructions: JsonUtils.asMap(json['payment_instructions']),
      items: JsonUtils.asMapList(
        json['items'],
      ).map(IkaPaymentItem.fromJson).toList(),
    );
  }
}

class IkaPaymentItem {
  const IkaPaymentItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.paymentStatus,
    this.type,
    this.typeLabel,
    this.description,
    this.dueDate,
    this.isRequired = false,
    this.paymentStatusLabel,
    this.paidAt,
    this.instructions = const {},
    this.payment,
  });

  final String id;
  final String title;
  final String? type;
  final String? typeLabel;
  final String? description;
  final double amount;
  final DateTime? dueDate;
  final bool isRequired;
  final String paymentStatus;
  final String? paymentStatusLabel;
  final DateTime? paidAt;
  final Map<String, dynamic> instructions;
  final IkaPaymentRecord? payment;

  factory IkaPaymentItem.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final paymentJson = JsonUtils.asMap(json['payment']);

    return IkaPaymentItem(
      id: JsonUtils.string(json, ['id']) ?? '',
      title: JsonUtils.string(json, ['title', 'name']) ?? '',
      type: JsonUtils.string(json, ['type']),
      typeLabel: JsonUtils.string(json, ['type_label', 'typeLabel']),
      description: JsonUtils.string(json, ['description']),
      amount: JsonUtils.decimal(json, ['amount']) ?? 0,
      dueDate: JsonUtils.dateTime(json, ['due_date', 'dueDate']),
      isRequired: JsonUtils.boolean(json, ['is_required', 'isRequired']),
      paymentStatus:
          JsonUtils.string(json, ['payment_status', 'paymentStatus']) ??
          'unpaid',
      paymentStatusLabel: JsonUtils.string(json, [
        'payment_status_label',
        'paymentStatusLabel',
      ]),
      paidAt: JsonUtils.dateTime(json, ['paid_at', 'paidAt']),
      instructions: JsonUtils.asMap(json['payment_instructions']),
      payment: paymentJson.isEmpty
          ? null
          : IkaPaymentRecord.fromJson(paymentJson),
    );
  }
}

class IkaPaymentRecord {
  const IkaPaymentRecord({
    required this.id,
    required this.paymentItemId,
    required this.title,
    required this.amount,
    required this.paymentStatus,
    this.type,
    this.paymentStatusLabel,
    this.paymentMethod,
    this.paymentNote,
    this.adminNote,
    this.proofFileUrl,
    this.paidAt,
    this.verifiedAt,
    this.rejectedAt,
  });

  final String id;
  final String paymentItemId;
  final String title;
  final String? type;
  final double amount;
  final String paymentStatus;
  final String? paymentStatusLabel;
  final String? paymentMethod;
  final String? paymentNote;
  final String? adminNote;
  final String? proofFileUrl;
  final DateTime? paidAt;
  final DateTime? verifiedAt;
  final DateTime? rejectedAt;

  factory IkaPaymentRecord.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaPaymentRecord(
      id: JsonUtils.string(json, ['id']) ?? '',
      paymentItemId:
          JsonUtils.string(json, ['payment_item_id', 'paymentItemId']) ?? '',
      title: JsonUtils.string(json, ['title', 'name']) ?? '',
      type: JsonUtils.string(json, ['type']),
      amount: JsonUtils.decimal(json, ['amount']) ?? 0,
      paymentStatus:
          JsonUtils.string(json, ['payment_status', 'paymentStatus']) ??
          'unpaid',
      paymentStatusLabel: JsonUtils.string(json, [
        'payment_status_label',
        'paymentStatusLabel',
      ]),
      paymentMethod: JsonUtils.string(json, [
        'payment_method',
        'paymentMethod',
      ]),
      paymentNote: JsonUtils.string(json, ['payment_note', 'paymentNote']),
      adminNote: JsonUtils.string(json, ['admin_note', 'adminNote']),
      proofFileUrl: JsonUtils.string(json, ['proof_file_url', 'proofFileUrl']),
      paidAt: JsonUtils.dateTime(json, ['paid_at', 'paidAt']),
      verifiedAt: JsonUtils.dateTime(json, ['verified_at', 'verifiedAt']),
      rejectedAt: JsonUtils.dateTime(json, ['rejected_at', 'rejectedAt']),
    );
  }
}
