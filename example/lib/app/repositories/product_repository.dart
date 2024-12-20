import 'package:snail/snail.dart';

import '../models/product_model.dart';

interface class ProductRepository extends SnailRepository<ProductModel, int> {
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
}
