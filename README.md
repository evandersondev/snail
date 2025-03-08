# 🐌 Snail: A Simple ORM-like Library for Flutter/Dart 🐦

**Snail** is a library inspired by Spring Boot's JPA, designed to simplify SQLite database management in Flutter/Dart applications. Easy to use like a snail 🐌 (but as functional as a rocket 🚀)!

## ✨ Features

- ✅ Create, Read, Update, Delete (CRUD) operations.
- 🔍 Dynamic query methods based on method naming conventions.
- 🛠️ Table creation based on field definitions.
- 🔄 Automatic mapping of entities to database rows and vice versa.
- 🔗 Support for snake_case and camelCase conversions.
- 📜 Pagination, sorting, and filtering support.

## 📥 Installation

Add the following dependency to your `pubspec.yaml`:

```yaml
dependencies:
  snail: ^1.1.3
```

## Getting Started 🏁

### Creating a Repository 📦

To create a repository for your model, extend the `SnailRepository` class:

```dart
import 'package:snail/snail.dart';

class UserRepository extends SnailRepository<User, int> {
  UserRepository() : super(
    tableName: 'users',
    primaryKeyColumn: 'id',
    defineFields: {
      'id': int,
      'name': String,
      'email': String,
      'isActive': bool,
    },
  );

  @override
  Map<String, dynamic> toMap(User entity) => entity.toMap();

  @override
  User fromMap(Map<String, dynamic> map) => User.fromMap(map);
}

class User {
  final int id;
  final String name;
  final String email;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
  });

   Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'email': email});
    result.addAll({'isActive': isActive});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      email: map['isActive'] ?? '',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Snail.initialize(
    repositories: [
      UserRepository(),
    ],
  );

  runApp(AppWidget());
}
```

### Using the Repository 🔧

```dart
void main() async {
  final userRepository = UserRepository();

  // Save a user
  await userRepository.save(User(id: 1, name: 'John Doe', email: 'john@example.com', isActive: true));

  // Find a user by ID
  final user = await userRepository.findById(1);

  // Find all users
  final users = await userRepository.findAll();

  // Delete a user
  await userRepository.deleteById(1);
}
```

## Dynamic Methods 🔍

The `dynamicMethod` allows constructing SQL queries based on the method naming. The naming structure should follow standard conventions:

### Naming Structure 🛠️

- **Prefixes**: `find` or `findAll`
- **Connectors**: `And`, `Or`
- **Operators**: `Between`, `LessThan`, `GreaterThan`, `Like`, `StartingWith`, `EndingWith`, `Containing`, `In`, `NotIn`, `OrderBy`, `True`, `False`, `IsNull`, `NotNull`

### Example Naming Conventions 📖

```dart
findByTitle(String title);
findById(int id);
findByTitleAndDescription(String title, String description);
findByTitleOrDescription(String title, String description);
findByTitleStartingWith(String title);
findByTitleEndingWith(String title);
findByTitleContaining(String title);
findByIdLessThan(int id);
findByIdGreaterThan(int id);
findByDateBetween(DateTime startDate, DateTime endDate);
findByTitleStartingWithAndIdLessThan(String title, int id);
findByTitleContainingOrDescriptionLike(String title, String description);
findByIdIn(List<int> ids);
findByIdNotIn(List<int> ids);
findByTitleOrderByDate(String title);
findByTitleOrderByDateDesc(String title);
findByTitleAndDescriptionOrderByDate(String title, String description);
findByIsActiveTrue();
findByIsActiveFalse();
findByTitleIsNull();
findByTitleNotNull();
```

### Usage Example 📝

```dart
Future<List<User>> findByTitleStartingWith(String title) {
  return dynamicMethod('findByTitleStartingWith', [title]);
}
```

## Filters: Pagination, Sorting, and Size 📊

Snail supports additional filtering through the `size`, `page`, and `sort` parameters:

- **`size`**: Specifies the number of records to fetch per page. Example: `size: 20`.
- **`page`**: Specifies the page number to fetch. Example: `page: 1` (fetches the first 20 records if `size` is set to 20).
- **`sort`**: Specifies the sorting order. Use the format `<field>,<order>`, where `<order>` can be `asc` or `desc`. Example: `sort: 'createdAt,asc'`.

By default, Snail applies a descending sort (`createdAt,desc`) if no sorting is specified.

### Example Usage 📝

```dart
Future<List<User>> findAllUsersWithPagination() async {
  return await userRepository.findAll(
    size: 20,
    page: 1,
    sort: 'createdAt,asc',
  );
}
```

## CRUD Operations ⚙️

### Save or Update an Entity 💾

```dart
Future<int> save(T entity);
```

### Save or Update Multiple Entities 💾💾

```dart
Future<List<int>> saveAll(List<T> entities);
```

### Find an Entity by ID 🔍

```dart
Future<T?> findById(ID id);
```

### Find All Entities 🔎

```dart
Future<List<T>> findAll({int? size, int? page, String? sort});
```

### Delete an Entity by ID 🗑️

```dart
Future<int> deleteById(ID id);
```

### Delete All Entities 🗑️🗑️

```dart
Future<int> deleteAll(List<T>? entities);
```

### Count Entities 🔢

```dart
Future<int> count();
```

## Automatic Fields: `createdAt` and `updatedAt` 🕒

Snail automatically adds `createdAt` and `updatedAt` fields to all models. These fields track when a record was created and last updated.

### Optional Usage in Models 📌

If you wish to explicitly include these fields in your model, you can define them as optional:

```dart
class TodoModel {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TodoModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool,
      createdAt: map['createdAt'] as DateTime?,
      updatedAt: map['updatedAt'] as DateTime?,
    );
  }
}
```

## Full API 📚

Below is the complete list of methods provided by Snail Repository:

| Method                                             | Description                                                      |
| -------------------------------------------------- | ---------------------------------------------------------------- |
| `save(T entity)`                                   | Saves or updates an entity in the database.                      |
| `saveAll(List<T> entities)`                        | Saves or updates multiple entities in the database.              |
| `findById(ID id)`                                  | Finds an entity by its primary key.                              |
| `findAll({int? size, int? page, String? sort})`    | Retrieves all entities with optional pagination and sorting.     |
| `deleteAll(List<T>? entities)`                     | Deletes all entities or a list of specified entities.            |
| `count()`                                          | Counts the total number of entities in the database.             |
| `dynamicMethod(String name, List<Object?> params)` | Executes a query based on the dynamic method naming conventions. |

## Contributing 🤝

Feel free to fork this repository and contribute by submitting a pull request. Your contributions are welcome! 💡

## License 📜

This project is licensed under the MIT License.

---

Made with ❤️ for Flutter developers! 🎯
