````dart
class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }
}

class UserRepository extends SnailRepository<UserModel, int> {
  UserRepository() : super(tableName: 'users', primaryKeyColumn: 'id');

  @override
  Map<String, dynamic> toMap(UserModel user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
    };
  }

  @override
  UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }

  @override
  int getId(UserModel user) {
    return user.id;
  }
}
```

```dart
class ProductModel {
  final int id;
  final String productName;
  final double price;

  ProductModel({required this.id, required this.productName, required this.price});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_name': productName,
      'price': price,
    };
  }

  ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      productName: map['product_name'],
      price: map['price'],
    );
  }
}

class ProductRepository extends SnailRepository<ProductModel, int> {
  ProductRepository() : super(tableName: 'products', primaryKeyColumn: 'id');

  @override
  Map<String, dynamic> toMap(ProductModel product) {
    return {
      'id': product.id,
      'product_name': product.productName,
      'price': product.price,
    };
  }

  @override
  ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      productName: map['product_name'],
      price: map['price'],
    );
  }

  @override
  int getId(ProductModel product) {
    return product.id;
  }
}
```

```dart
void main() async {
  // Inicializar o banco de dados e criar as tabelas
  await Snail.initialize(models: [
    {
      'tableName': 'users',
      'primaryKeyColumn': 'id',
      'model': UserModel,
    },
    {
      'tableName': 'products',
      'primaryKeyColumn': 'id',
      'model': ProductModel,
    }
  ]);

  // Criar instâncias dos repositórios
  final userRepo = UserRepository();
  final productRepo = ProductRepository();

  // Criar e salvar usuários
  await userRepo.create(UserModel(id: 1, name: 'John Doe', email: 'john@example.com'));
  await userRepo.create(UserModel(id: 2, name: 'Jane Doe', email: 'jane@example.com'));

  // Criar e salvar produtos
  await productRepo.create(ProductModel(id: 1, productName: 'Laptop', price: 999.99));
  await productRepo.create(ProductModel(id: 2, productName: 'Smartphone', price: 499.99));

  // Consultar usuários
  final users = await userRepo.findMany();
  print('Users: $users');

  // Consultar produtos
  final products = await productRepo.findMany();
  print('Products: $products');
}
```
````
