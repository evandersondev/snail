# 🐌 Snail: A Simple ORM-like Library for Flutter/Dart 🐦

**Snail** is a library inspired by Spring Boot's JPA, designed to simplify SQLite database management in Flutter/Dart applications. Easy to use like a snail 🐌 (but as functional as a rocket 🚀)!

---

## 🌟 Features

- 📦 **Automatic table creation** in SQLite based on repositories.
- 🔄 Ready-to-use **CRUD methods**: _create_, _read_, _update_, _delete_.
- 🛠️ **Batch operations** like `createMany` and `findMany`.
- 💡 Abstraction with `SnailRepository` and straightforward entity mapping.

---

## 🚀 Installation

Add Snail to your project by including it in `pubspec.yaml`:

```yaml
dependencies:
  snail: ^1.0.3
```

Install the dependency:

```bash
flutter pub get
```

---

## 🛠️ Initial Setup

### 1 - **Define Your Model**

Create a class representing your database entity:

```dart
class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        name: map['name'],
        email: map['email'],
      );
}
```

---

### 2 - **Create the Repository**

Extend the `SnailRepository` to define your data repository:

```dart
import 'package:snail/snail.dart';
import '../models/user_model.dart';

class UserRepository extends SnailRepository<UserModel, int> {
  UserRepository()
      : super(
          tableName: 'users',
          primaryKeyColumn: 'id',
          defineFields: {
            'id': int,
            'name': String,
            'email': String,
          },
        );

  @override
  Map<String, dynamic> toMap(UserModel entity) => entity.toMap();

  @override
  UserModel fromMap(Map<String, dynamic> map) => UserModel.fromMap(map);
}
```

---

### 3 - **Initialize the Database**

Configure repositories in the `main()` function:

```dart
import 'package:flutter/material.dart';
import 'package:snail/snail.dart';
import './repositories/user_repository.dart';

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

---

## 🎉 **Usage Examples**

### 📌 Create a New Record

```dart
final userRepo = UserRepository();
await userRepo.create(UserModel(id: 1, name: 'John Doe', email: 'john@example.com'));
```

### 🔍 Fetch a Record by ID

```dart
final user = await userRepo.findOne(1);
if (user != null) {
  print('User found: ${user.name}');
}
```

### 📋 Fetch All Records

```dart
final users = await userRepo.findMany();
users.forEach((user) => print(user.name));
```

### 🛠️ Update a Record

```dart
final updatedUser = UserModel(id: 1, name: 'Jane Doe', email: 'jane@example.com');
await userRepo.update(updatedUser);
```

### 🗑️ Delete a Record

```dart
await userRepo.delete(1);
```

### 🚀 Create Multiple Records

```dart
await userRepo.createMany([
  UserModel(id: 2, name: 'Alice', email: 'alice@example.com'),
  UserModel(id: 3, name: 'Bob', email: 'bob@example.com'),
]);
```

---

## 🧬 **Full API**

### CRUD Methods:

| Method                 | Description               |
| ---------------------- | ------------------------- |
| `create(T entity)`     | Creates a new record.     |
| `createMany(List<T>)`  | Creates multiple records. |
| `findOne(ID id)`       | Fetches a record by ID.   |
| `findMany()`           | Fetches all records.      |
| `update(T entity)`     | Updates a record.         |
| `updateMany(List<T>)`  | Updates multiple records. |
| `delete(ID id)`        | Deletes a record by ID.   |
| `deleteMany(List<ID>)` | Deletes multiple records. |

---

## 🧪 **Testing**

A basic unit test example:

```dart
void main() async {
  final repo = UserRepository();

  await repo.create(UserModel(id: 1, name: 'Test User', email: 'test@test.com'));
  final user = await repo.findOne(1);

  assert(user?.name == 'Test User');
  print('Test passed 🎉');
}
```

---

## 💛 **Contributing**

Contributions are always welcome! Open an issue or submit a pull request on the GitHub repository.

---

## 📜 **License**

This project is licensed under the **MIT License**.

---

## 🚀 **Ready to Simplify Your SQLite?**

Boost your productivity with **Snail** and make your SQLite operations simple and efficient! 🐌💨

---

**Made with ❤️ for Flutter developers!** 🎯
