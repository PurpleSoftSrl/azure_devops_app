import 'dart:convert';

class AmazonItem {
  AmazonItem({
    required this.id,
    required this.itemUrl,
    required this.title,
    required this.imageUrl,
    required this.isPrime,
    required this.originalPrice,
    required this.discount,
    required this.discountedPrice,
    required this.currency,
  });

  factory AmazonItem.fromJson(Map<String, dynamic> json) => AmazonItem(
    id: json['id'] as String? ?? '',
    itemUrl: json['itemUrl'] as String? ?? '',
    title: json['title'] as String? ?? '',
    imageUrl: json['imageUrl'] as String? ?? '',
    isPrime: json['isPrime'] as bool? ?? false,
    originalPrice: Price.fromJson(json['originalPrice'] as Map<String, dynamic>? ?? {}),
    discount: json['discount'] == null ? null : Discount.fromJson(json['discount'] as Map<String, dynamic>? ?? {}),
    discountedPrice: Price.fromJson(json['discountedPrice'] as Map<String, dynamic>? ?? {}),
    currency: json['currency'] as String? ?? '',
  );

  static List<AmazonItem> listFromJson(String str) => List<AmazonItem>.from(
    (json.decode(str) as List<dynamic>? ?? []).map((x) => AmazonItem.fromJson(x as Map<String, dynamic>? ?? {})),
  );

  final String id;
  final String itemUrl;
  final String title;
  final String imageUrl;
  final bool isPrime;
  final Price originalPrice;
  final Discount? discount;
  final Price discountedPrice;
  final String currency;

  @override
  bool operator ==(covariant AmazonItem other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

class Discount {
  Discount({required this.amount, required this.percentage});

  factory Discount.fromJson(Map<String, dynamic> json) =>
      Discount(amount: (json['amount'] as num?)?.toDouble() ?? 0, percentage: json['percentage'] as int? ?? 0);

  final double amount;
  final int percentage;
}

class Price {
  Price({required this.amount});

  factory Price.fromJson(Map<String, dynamic> json) => Price(amount: (json['amount'] as num?)?.toDouble() ?? 0);

  final double amount;
}
