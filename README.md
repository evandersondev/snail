# 🐌 Snail: A Simple ORM-like Library for Flutter/Dart 🐦

**Snail** é uma biblioteca inspirada no JPA do Spring Boot que facilita o gerenciamento de banco de dados SQLite em aplicações Flutter/Dart. Rápido de usar e simples como uma lesma 🐌 (mas funcional como um foguete 🚀)!

## 🌟 Recursos

- 📦 Criação automática de tabelas no SQLite com base em repositórios.
- 🔄 Métodos CRUD prontos: _create_, _read_, _update_, _delete_.
- 🛠️ Manipulação de múltiplos registros com `createMany`, `findMany`, etc.
- 💡 Abstração com `SnailRepository` e mapeamento simples de entidades.

---

## 🚀 Instalação

Adicione o Snail ao seu projeto no `pubspec.yaml`:

```yaml
dependencies:
  snail: ^1.0.2
```

Instale com:

```bash
flutter pub get
```

---

## 🛠️ Configuração Inicial

### 1⃣ **Defina seu Modelo**

Crie uma classe representando a entidade:

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

### 2⃣ **Crie o Repositório**

Extenda o `SnailRepository` para definir o repositório de dados:

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

### 3⃣ **Inicialize o Banco de Dados**

Configure os repositórios no `main()`:

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

## 🎉 **Exemplo de Uso**

### 📌 Criar um Novo Registro

```dart
final userRepo = UserRepository();
await userRepo.create(UserModel(id: 1, name: 'John Doe', email: 'john@example.com'));
```

### 🔍 Buscar um Registro por ID

```dart
final user = await userRepo.findOne(1);
if (user != null) {
  print('User found: ${user.name}');
}
```

### 📋 Buscar Todos os Registros

```dart
final users = await userRepo.findMany();
users.forEach((user) => print(user.name));
```

### 🛠️ Atualizar um Registro

```dart
final updatedUser = UserModel(id: 1, name: 'Jane Doe', email: 'jane@example.com');
await userRepo.update(updatedUser);
```

### 🗑️ Deletar um Registro

```dart
await userRepo.delete(1);
```

### 🚀 Criar Vários Registros

```dart
await userRepo.createMany([
  UserModel(id: 2, name: 'Alice', email: 'alice@example.com'),
  UserModel(id: 3, name: 'Bob', email: 'bob@example.com'),
]);
```

---

## 🧪 **API Completa**

### Métodos CRUD:

| Método                 | Descrição                     |
| ---------------------- | ----------------------------- |
| `create(T entity)`     | Cria um novo registro.        |
| `createMany(List<T>)`  | Cria múltiplos registros.     |
| `findOne(ID id)`       | Busca um registro por ID.     |
| `findMany()`           | Busca todos os registros.     |
| `update(T entity)`     | Atualiza um registro.         |
| `updateMany(List<T>)`  | Atualiza múltiplos registros. |
| `delete(ID id)`        | Deleta um registro pelo ID.   |
| `deleteMany(List<ID>)` | Deleta múltiplos registros.   |

---

## 🧬 **Testando**

Exemplo básico de teste unitário:

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

## 💛 **Contribuindo**

Contribuições são super bem-vindas! Abra uma _issue_ ou envie um _pull request_ no repositório do GitHub.

---

## 📜 **Licença**

Este projeto está licenciado sob a licença **MIT**.

---

## 🚀 **Pronto para usar?**

Dê um _push_ na sua produtividade com **Snail** e torne suas operações no SQLite mais simples e rápidas! 🐌💨

---

**Made with ❤️ for Flutter developers!** 🎯
