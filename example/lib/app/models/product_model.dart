import 'dart:convert';

import 'package:snail/snail.dart';

class ProductModel extends SnailTableModel {
  final int id;
  final String productName;
  final double price;

  ProductModel({
    required this.id,
    required this.productName,
    required this.price,
  });

  @override
  SnailTableMetadata get metadata => SnailTableMetadata(
        tableName: 'products',
        primaryKeyColumn: 'id',
        fields: [id, productName, price],
      );

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'productName': productName});
    result.addAll({'price': price});

    return result;
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toInt() ?? 0,
      productName: map['productName'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source));
}
