import 'package:snail/snail.dart';

import '../models/product_model.dart';

class ProductRepository extends SnailRepository<ProductModel, int> {
  ProductRepository()
      : super(
          tableName: 'products',
          primaryKeyColumn: 'id',
          defineFields: {
            'id': int,
            'productName': String,
            'price': double,
          },
        );

  @override
  ProductModel fromMap(Map<String, dynamic> map) => ProductModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(ProductModel entity) => entity.toMap();
}
