import 'package:snail/snail.dart';

import '../models/product_model.dart';

class ProductRepository extends SnailRepository<ProductModel, int> {
  ProductRepository() : super(tableName: 'products', primaryKeyColumn: 'id');

  @override
  ProductModel fromMap(Map<String, dynamic> map) => ProductModel.fromMap(map);

  @override
  int getId(ProductModel entity) => entity.id;

  @override
  Map<String, dynamic> toMap(ProductModel entity) => entity.toMap();
}
