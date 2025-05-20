import 'dart:io';
import 'package:flutter/material.dart' as dev show debugPrint;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // For utf8.encode

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) {
      dev.debugPrint('DatabaseHelper: Using existing database');
      return _database!;
    }
    dev.debugPrint('DatabaseHelper: Initializing new database');
    _database = await _initDatabase();
    await _seedDataIfEmpty();
    dev.debugPrint('DatabaseHelper: Database initialization complete');
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'drophope.db');
    dev.debugPrint('DatabaseHelper: Database path: $path');
    return await openDatabase(
      path,
      version: 9, // Incremented version for new migration
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen:
          (db) =>
              dev.debugPrint('DatabaseHelper: Database opened successfully'),
    );
  }

  Future<void> exportDatabase() async {
    try {
      final dbPath = join(await getDatabasesPath(), 'drophope.db');
      final exportDir = await getExternalStorageDirectory();
      final exportPath = join(exportDir!.path, 'drophope_export.db');
      await File(dbPath).copy(exportPath);
      dev.debugPrint('DatabaseHelper: Database exported to $exportPath');
    } catch (e) {
      dev.debugPrint('DatabaseHelper: Error exporting database: $e');
    }
  }

  Future<void> _seedDataIfEmpty() async {
    final db = await database;
    final userCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM users'),
        ) ??
        0;
    dev.debugPrint('DatabaseHelper: User count from database: $userCount');
    if (userCount == 0) {
      dev.debugPrint('DatabaseHelper: No users found, seeding database');
      await _seedItems(db);
      dev.debugPrint('DatabaseHelper: Seeding completed, verifying user count');
      final newUserCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM users'),
          ) ??
          0;
      dev.debugPrint(
        'DatabaseHelper: New user count after seeding: $newUserCount',
      );
    } else {
      dev.debugPrint(
        'DatabaseHelper: Found $userCount users, no seeding needed',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    dev.debugPrint('DatabaseHelper: Creating database with version $version');
    await db.execute('''
      CREATE TABLE users (
        email TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        password TEXT NOT NULL,
        profile_picture TEXT,
        account_type TEXT NOT NULL DEFAULT 'BASIC',
        role TEXT NOT NULL DEFAULT 'user' -- Added role column
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        image_path TEXT,
        uploader_email TEXT NOT NULL,
        uploader_name TEXT NOT NULL,
        phone TEXT,
        FOREIGN KEY (uploader_email) REFERENCES users(email)
      )
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reporter_email TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Pending',
        FOREIGN KEY (reporter_email) REFERENCES users(email),
        FOREIGN KEY (item_id) REFERENCES items(id)
      )
    ''');

    await _seedItems(db);
    dev.debugPrint('DatabaseHelper: Tables created and seeded');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    dev.debugPrint(
      'DatabaseHelper: Upgrading database from version $oldVersion to $newVersion',
    );
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          email TEXT PRIMARY KEY,
          full_name TEXT NOT NULL,
          password TEXT NOT NULL,
          role TEXT NOT NULL DEFAULT 'user' -- Added in migration
        )
      ''');
      final existingItems = await db.query('items');
      for (var item in existingItems) {
        final uploaderEmail = item['uploader_email'] as String?;
        if (uploaderEmail != null) {
          final fullName =
              uploaderEmail.split('@')[0].replaceAll('.', ' ').toTitleCase();
          await db.insert('users', {
            'email': uploaderEmail,
            'full_name': fullName,
            'password': 'defaultpass',
            'role': 'user', // Default role for existing users
          });
        }
      }
    }
    if (oldVersion < 3) {
      dev.debugPrint(
        'DatabaseHelper: Migrating to version 3, adding full_name column to users table',
      );
      final columns = await db.rawQuery('PRAGMA table_info(users)');
      final hasFullNameColumn = columns.any(
        (col) => col['name'] == 'full_name',
      );
      if (!hasFullNameColumn) {
        await db.execute('ALTER TABLE users ADD COLUMN full_name TEXT');
        dev.debugPrint('DatabaseHelper: Added full_name column to users table');
        final users = await db.query('users');
        for (var user in users) {
          final email = user['email'] as String?;
          if (email != null) {
            final fullName =
                email.split('@')[0].replaceAll('.', ' ').toTitleCase();
            await db.update(
              'users',
              {'full_name': fullName},
              where: 'email = ?',
              whereArgs: [email],
            );
          }
        }
        dev.debugPrint('DatabaseHelper: Updated full_name for existing users');
      }
      await db.execute(
        'UPDATE users SET full_name = "Unknown" WHERE full_name IS NULL',
      );
      dev.debugPrint(
        'DatabaseHelper: Set default full_name for any null entries',
      );
    }
    if (oldVersion < 4) {
      dev.debugPrint(
        'DatabaseHelper: Migrating to version 4, adding uploader_name to items table',
      );
      final columns = await db.rawQuery('PRAGMA table_info(items)');
      final hasUploaderNameColumn = columns.any(
        (col) => col['name'] == 'uploader_name',
      );
      if (!hasUploaderNameColumn) {
        await db.execute(
          'ALTER TABLE items ADD COLUMN uploader_name TEXT NOT NULL DEFAULT "Unknown"',
        );
        dev.debugPrint(
          'DatabaseHelper: Added uploader_name column to items table',
        );
        final items = await db.query('items');
        for (var item in items) {
          final uploaderEmail = item['uploader_email'] as String?;
          if (uploaderEmail != null) {
            final user = await db.query(
              'users',
              where: 'email = ?',
              whereArgs: [uploaderEmail],
            );
            final fullName =
                user.isNotEmpty
                    ? user.first['full_name'] as String? ?? 'Unknown'
                    : 'Unknown';
            await db.update(
              'items',
              {'uploader_name': fullName},
              where: 'uploader_email = ?',
              whereArgs: [uploaderEmail],
            );
          }
        }
        dev.debugPrint(
          'DatabaseHelper: Updated uploader_name for existing items',
        );
      }
    }
    if (oldVersion < 5) {
      dev.debugPrint(
        'DatabaseHelper: Migrating to version 5, ensuring uploader_name is NOT NULL',
      );
      final columns = await db.rawQuery('PRAGMA table_info(items)');
      final hasUploaderNameColumn = columns.any(
        (col) => col['name'] == 'uploader_name',
      );
      if (!hasUploaderNameColumn) {
        await db.execute(
          'ALTER TABLE items ADD COLUMN uploader_name TEXT NOT NULL DEFAULT "Unknown"',
        );
        dev.debugPrint(
          'DatabaseHelper: Added uploader_name column to items table in version 5',
        );
      }
      await db.execute(
        'UPDATE items SET uploader_name = "Unknown" WHERE uploader_name IS NULL',
      );
      final items = await db.query('items');
      for (var item in items) {
        final uploaderEmail = item['uploader_email'] as String?;
        if (uploaderEmail != null) {
          final user = await db.query(
            'users',
            where: 'email = ?',
            whereArgs: [uploaderEmail],
          );
          final fullName =
              user.isNotEmpty
                  ? user.first['full_name'] as String? ?? 'Unknown'
                  : 'Unknown';
          await db.update(
            'items',
            {'uploader_name': fullName},
            where: 'uploader_email = ?',
            whereArgs: [uploaderEmail],
          );
        }
      }
      dev.debugPrint(
        'DatabaseHelper: Ensured uploader_name for all items in version 5',
      );
    }
    if (oldVersion < 6) {
      dev.debugPrint(
        'DatabaseHelper: Migrating to version 6, adding profile_picture to users table',
      );
      final columns = await db.rawQuery('PRAGMA table_info(users)');
      final hasProfilePictureColumn = columns.any(
        (col) => col['name'] == 'profile_picture',
      );
      if (!hasProfilePictureColumn) {
        await db.execute('ALTER TABLE users ADD COLUMN profile_picture TEXT');
        dev.debugPrint(
          'DatabaseHelper: Added profile_picture column to users table',
        );
      }
    }
    if (oldVersion < 7) {
      dev.debugPrint(
        'DatabaseHelper: Migrating to version 7, adding account_type to users table',
      );
      final columns = await db.rawQuery('PRAGMA table_info(users)');
      final hasAccountTypeColumn = columns.any(
        (col) => col['name'] == 'account_type',
      );
      if (!hasAccountTypeColumn) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN account_type TEXT NOT NULL DEFAULT "BASIC"',
        );
        dev.debugPrint(
          'DatabaseHelper: Added account_type column to users table',
        );
      }
      await db.execute(
        'UPDATE users SET account_type = "BASIC" WHERE account_type IS NULL',
      );
      dev.debugPrint(
        'DatabaseHelper: Set default account_type to BASIC for existing users',
      );
    }
    if (oldVersion < 8) {
      dev.debugPrint(
        'DatabaseHelper: Migrating to version 8, adding reports table',
      );
      await db.execute('''
        CREATE TABLE reports (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          reporter_email TEXT NOT NULL,
          item_id INTEGER NOT NULL,
          reason TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'Pending',
          FOREIGN KEY (reporter_email) REFERENCES users(email),
          FOREIGN KEY (item_id) REFERENCES items(id)
        )
      ''');
      dev.debugPrint('DatabaseHelper: Added reports table in version 8');
    }
    if (oldVersion < 9) {
      dev.debugPrint(
        'DatabaseHelper: Migrating to version 9, adding role column to users table',
      );
      final columns = await db.rawQuery('PRAGMA table_info(users)');
      final hasRoleColumn = columns.any((col) => col['name'] == 'role');
      if (!hasRoleColumn) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT "user"',
        );
        dev.debugPrint('DatabaseHelper: Added role column to users table');
      }
      await db.execute('UPDATE users SET role = "user" WHERE role IS NULL');
      dev.debugPrint(
        'DatabaseHelper: Set default role to user for existing users',
      );
    }
  }

  // Helper method to hash passwords using SHA-256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert string to bytes
    var digest = sha256.convert(bytes); // Hash using SHA-256
    return digest.toString(); // Return hexadecimal string
  }

  Future<void> _seedItems(Database db) async {
    // Seed admin user
    await db.insert('users', {
      'email': 'admin@drophope.com',
      'full_name': 'Admin User',
      'password': _hashPassword('adminpass123'), // Hash the password
      'profile_picture': null,
      'account_type': 'ADMIN',
      'role': 'admin', // Set role to admin
    });

    // Seed regular users
    await db.insert('users', {
      'email': 'aya@example.com',
      'full_name': 'Aya',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'aymen@example.com',
      'full_name': 'Aymen',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'mohamed@example.com',
      'full_name': 'Mohamed',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'arwa@example.com',
      'full_name': 'Arwa',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'charlie@example.com',
      'full_name': 'Charlie',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'eve@example.com',
      'full_name': 'Eve',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'frank@example.com',
      'full_name': 'Frank',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'gina@example.com',
      'full_name': 'Gina',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'hank@example.com',
      'full_name': 'Hank',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'dave@example.com',
      'full_name': 'Dave',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'grace@example.com',
      'full_name': 'Grace',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'riyad@example.com',
      'full_name': 'Riyad',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'walid@example.com',
      'full_name': 'Walid',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'yacine@example.com',
      'full_name': 'Yacine',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'sahraoui@example.com',
      'full_name': 'Sahraoui',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'farid@example.com',
      'full_name': 'Farid',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'amine@example.com',
      'full_name': 'Amine',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'noah@example.com',
      'full_name': 'Noah',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'isabella@example.com',
      'full_name': 'Isabella',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'akrem@example.com',
      'full_name': 'Akrem',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'oumaima@example.com',
      'full_name': 'Oumaima',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'souhila@example.com',
      'full_name': 'Souhila',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'farouk@example.com',
      'full_name': 'Farouk',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });
    await db.insert('users', {
      'email': 'tina@example.com',
      'full_name': 'Tina',
      'password': _hashPassword('password123'), // Hash the password
      'profile_picture': null,
      'account_type': 'BASIC',
      'role': 'user',
    });

    await db.insert('items', {
      'title': 'Apples',
      'description': 'Fresh apples from my garden',
      'type': 'Free',
      'category': 'Free food',
      'image_path': 'assets/images/apples.jpg',
      'uploader_email': 'aya@example.com',
      'uploader_name': 'Aya',
      'phone': '0797098003',
    });
    await db.insert('items', {
      'title': 'Bread',
      'description': 'Homemade sourdough bread',
      'type': 'Free',
      'category': 'Free food',
      'image_path': 'assets/items_images/bread.jpg',
      'uploader_email': 'aymen@example.com',
      'uploader_name': 'Aymen',
      'phone': '0558836991',
    });
    await db.insert('items', {
      'title': 'Canned Soup',
      'description': 'Unopened cans of tomato soup, expires next month.',
      'type': 'Free',
      'category': 'Free food',
      'image_path': 'assets/items_images/canned.webp',
      'uploader_email': 'mohamed@example.com',
      'uploader_name': 'Mohamed',
      'phone': '0774836991',
    });
    await db.insert('items', {
      'title': 'Vegetable Basket',
      'description': 'Mixed vegetables from my garden, free for pickup.',
      'type': 'Free',
      'category': 'Free food',
      'image_path': 'assets/items_images/vegetable.webp',
      'uploader_email': 'arwa@example.com',
      'uploader_name': 'Arwa',
      'phone': '0669522761',
    });
    await db.insert('items', {
      'title': 'Books',
      'description': 'Assorted novels',
      'type': 'Free',
      'category': 'Free items',
      'image_path': 'assets/items_images/books.jpg',
      'uploader_email': 'charlie@example.com',
      'uploader_name': 'Charlie',
      'phone': '0774836991',
    });
    await db.insert('items', {
      'title': 'Wooden Chair',
      'description': 'Slightly used, sturdy wooden chair.',
      'type': 'Free',
      'category': 'Free items',
      'image_path': 'assets/items_images/chair.webp',
      'uploader_email': 'eve@example.com',
      'uploader_name': 'Eve',
      'phone': '0567890124',
    });
    await db.insert('items', {
      'title': 'Kids\' Toys',
      'description': 'Plush toys, cleaned and ready for a new home.',
      'type': 'Free',
      'category': 'Free items',
      'image_path': 'assets/items_images/toys.jpg',
      'uploader_email': 'frank@example.com',
      'uploader_name': 'Frank',
      'phone': '6789012345',
    });
    await db.insert('items', {
      'title': 'Clothing Bundle',
      'description': 'Assorted clothes, mostly for adults, free to take.',
      'type': 'Free',
      'category': 'Free items',
      'image_path': 'assets/items_images/clothes.jpg',
      'uploader_email': 'gina@example.com',
      'uploader_name': 'Gina',
      'phone': '0567890123',
    });
    await db.insert('items', {
      'title': 'Picture Frames',
      'description': 'Set of 3 picture frames, slightly used.',
      'type': 'Free',
      'category': 'Free items',
      'image_path': 'assets/items_images/frames.jpg',
      'uploader_email': 'hank@example.com',
      'uploader_name': 'Hank',
      'phone': '0552347685',
    });
    await db.insert('items', {
      'title': 'Chair',
      'description': 'Desktop chair in good condition',
      'type': 'Cheap',
      'category': 'For sale',
      'image_path': 'assets/items_images/dchair.jpg',
      'uploader_email': 'dave@example.com',
      'uploader_name': 'Dave',
      'phone': '0542198752',
    });
    await db.insert('items', {
      'title': 'Desk Lamp',
      'description': 'Works well, 200DZD.',
      'type': 'Cheap',
      'category': 'For sale',
      'image_path': 'assets/items_images/lamp.jpg',
      'uploader_email': 'grace@example.com',
      'uploader_name': 'Grace',
      'phone': '07890123456',
    });
    await db.insert('items', {
      'title': 'Bicycle',
      'description': 'Needs minor repair, 1500DZD.',
      'type': 'Cheap',
      'category': 'For sale',
      'image_path': 'assets/items_images/bycycle.jpg',
      'uploader_email': 'riyad@example.com',
      'uploader_name': 'Riyad',
      'phone': '0665511777',
    });
    await db.insert('items', {
      'title': 'Headphones',
      'description': 'Used headphones, good condition, 500DZD.',
      'type': 'Cheap',
      'category': 'For sale',
      'image_path': 'assets/items_images/headphones.jpg',
      'uploader_email': 'aya@example.com',
      'uploader_name': 'Aya',
      'phone': '0123456789',
    });
    await db.insert('items', {
      'title': 'Coffee Table',
      'description': 'Small coffee table, 1000DZD.',
      'type': 'Cheap',
      'category': 'For sale',
      'image_path': 'assets/items_images/table.webp',
      'uploader_email': 'walid@example.com',
      'uploader_name': 'Walid',
      'phone': '0665244877',
    });
    await db.insert('items', {
      'title': 'Ladder',
      'description': '6ft aluminum ladder',
      'type': 'Rent',
      'category': 'Rent',
      'image_path': 'assets/items_images/ladder.jpg',
      'uploader_email': 'eve@example.com',
      'uploader_name': 'Eve',
      'phone': '0668595552',
    });
    await db.insert('items', {
      'title': 'Camping Tent',
      'description': '2-person tent, borrow for a weekend.',
      'type': 'Rent',
      'category': 'Rent',
      'image_path': 'assets/items_images/tent.jpg',
      'uploader_email': 'yacine@example.com',
      'uploader_name': 'Yacine',
      'phone': '0665785234',
    });
    await db.insert('items', {
      'title': 'Power Drill',
      'description': 'Cordless drill, borrow for a day.',
      'type': 'Rent',
      'category': 'Rent',
      'image_path': 'assets/items_images/drill.jpg',
      'uploader_email': 'sahraoui@example.com',
      'uploader_name': 'Sahraoui',
      'phone': '0661536164',
    });
    await db.insert('items', {
      'title': 'Projector',
      'description': 'Portable projector, borrow for an event.',
      'type': 'Rent',
      'category': 'Rent',
      'image_path': 'assets/items_images/projector.jpg',
      'uploader_email': 'farid@example.com',
      'uploader_name': 'Farid',
      'phone': '0744885563',
    });
    await db.insert('items', {
      'title': 'Gardening Tools',
      'description': 'Looking for shovels or rakes',
      'type': 'Wanted',
      'category': 'Wanted',
      'image_path': 'assets/items_images/tools.jpg',
      'uploader_email': 'frank@example.com',
      'uploader_name': 'Frank',
      'phone': '0669888552',
    });
    await db.insert('items', {
      'title': 'Winter Jacket',
      'description': 'Looking for a size M winter jacket.',
      'type': 'Wanted',
      'category': 'Wanted',
      'image_path': 'assets/items_images/jacket.jpg',
      'uploader_email': 'amine@example.com',
      'uploader_name': 'Amine',
      'phone': '0667788555',
    });
    await db.insert('items', {
      'title': 'Textbooks',
      'description': 'Need math textbooks for high school.',
      'type': 'Wanted',
      'category': 'Wanted',
      'image_path': 'assets/items_images/textbooks.jpg',
      'uploader_email': 'noah@example.com',
      'uploader_name': 'Noah',
      'phone': '0677854321',
    });
    await db.insert('items', {
      'title': 'Baby Stroller',
      'description': 'Seeking a gently used stroller.',
      'type': 'Wanted',
      'category': 'Wanted',
      'image_path': 'assets/items_images/stroller.jpg',
      'uploader_email': 'isabella@example.com',
      'uploader_name': 'Isabella',
      'phone': '0665771234',
    });
    await db.insert('items', {
      'title': 'Laptop Charger',
      'description': 'Need a charger for a Dell laptop.',
      'type': 'Wanted',
      'category': 'Wanted',
      'image_path': 'assets/items_images/charger.jpg',
      'uploader_email': 'akrem@example.com',
      'uploader_name': 'Akrem',
      'phone': '0568888888',
    });
    await db.insert('items', {
      'title': 'Community Event',
      'description': 'Discussion about local cleanup',
      'type': 'Forum',
      'category': 'Forum',
      'image_path': 'assets/items_images/event.png',
      'uploader_email': 'oumaima@example.com',
      'uploader_name': 'Oumaima',
      'phone': '0586629876',
    });
    await db.insert('items', {
      'title': 'Recipe Share',
      'description': 'Share your favorite recipes with the community.',
      'type': 'Forum',
      'category': 'Forum',
      'image_path': 'assets/items_images/recipe.jpg',
      'uploader_email': 'souhila@example.com',
      'uploader_name': 'Souhila',
      'phone': '0599665432',
    });
    await db.insert('items', {
      'title': 'Coding Club',
      'description': 'Starting a local Coding club, join us!',
      'type': 'Forum',
      'category': 'Forum',
      'image_path': 'assets/items_images/club.png',
      'uploader_email': 'farouk@example.com',
      'uploader_name': 'Farouk',
      'phone': '0598755432',
    });
    await db.insert('items', {
      'title': 'Book Exchange',
      'description': 'Organizing a book exchange event next month.',
      'type': 'Forum',
      'category': 'Forum',
      'image_path': 'assets/items_images/booke.avif',
      'uploader_email': 'tina@example.com',
      'uploader_name': 'Tina',
      'phone': '0785556789',
    });
    dev.debugPrint('DatabaseHelper: Seeding of 27 items completed');
  }

  Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT items.*, users.full_name AS uploader_name
        FROM items
        LEFT JOIN users ON items.uploader_email = users.email
      ''');
      dev.debugPrint(
        'DatabaseHelper: Retrieved ${result.length} items from database',
      );
      for (var item in result) {
        dev.debugPrint(
          'DatabaseHelper: Item ${item['title']} has uploader_email: ${item['uploader_email']}, uploader_name: ${item['uploader_name'] ?? 'Unknown'}',
        );
      }
      return result;
    } catch (e) {
      dev.debugPrint('DatabaseHelper: Error in getAllItems: $e');
      final fallbackResult = await db.query('items');
      dev.debugPrint(
        'DatabaseHelper: Fallback retrieved ${fallbackResult.length} items',
      );
      return fallbackResult
          .map(
            (item) => {
              ...item,
              'uploader_name': item['uploader_name'] ?? 'Unknown',
            },
          )
          .toList();
    }
  }

  Future<int> insertItem(Map<String, dynamic> row) async {
    final db = await database;
    final user = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [row['uploader_email']],
    );
    final uploaderName =
        user.isNotEmpty
            ? user.first['full_name'] as String? ?? 'Unknown'
            : 'Unknown';
    final updatedRow = {
      'title': row['title'],
      'description': row['description'],
      'type': row['type'],
      'category': row['category'],
      'image_path': row['image_path'],
      'uploader_email': row['uploader_email'],
      'uploader_name': row['uploader_name'] ?? uploaderName,
      'phone': row['phone'],
    };
    final id = await db.insert('items', updatedRow);
    dev.debugPrint(
      'DatabaseHelper: Inserted item with id $id, uploader_email: ${row['uploader_email']}, uploader_name: ${updatedRow['uploader_name']}',
    );
    return id;
  }

  Future<int> updateItem(int id, Map<String, dynamic> row) async {
    final db = await database;
    final user = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [row['uploader_email']],
    );
    final uploaderName =
        user.isNotEmpty
            ? user.first['full_name'] as String? ?? 'Unknown'
            : 'Unknown';
    final updatedRow = {
      'title': row['title'],
      'description': row['description'],
      'type': row['type'],
      'category': row['category'],
      'image_path': row['image_path'],
      'uploader_email': row['uploader_email'],
      'uploader_name': row['uploader_name'] ?? uploaderName,
      'phone': row['phone'],
    };
    final count = await db.update(
      'items',
      updatedRow,
      where: 'id = ?',
      whereArgs: [id],
    );
    dev.debugPrint(
      'DatabaseHelper: Updated $count item(s) with id $id, uploader_name: ${updatedRow['uploader_name']}',
    );
    return count;
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    final count = await db.delete('items', where: 'id = ?', whereArgs: [id]);
    dev.debugPrint('DatabaseHelper: Deleted $count item(s) with id $id');
    return count;
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await database;
    final fullName = row['full_name'] as String? ?? 'Unknown';
    final password = row['password'] as String? ?? '';
    final updatedRow = {
      ...row,
      'full_name': fullName,
      'password': _hashPassword(password), // Hash the password
      'profile_picture': row['profile_picture'],
      'account_type': row['account_type'] ?? 'BASIC',
      'role': row['role'] ?? 'user', // Ensure role is set
    };
    final id = await db.insert(
      'users',
      updatedRow,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    dev.debugPrint(
      'DatabaseHelper: Inserted/updated user with email ${row['email']}, full_name: $fullName, profile_picture: ${row['profile_picture']}, account_type: ${updatedRow['account_type']}, role: ${updatedRow['role']}',
    );
    return id;
  }

  Future<int> updateUserProfilePicture(
    String email,
    String? profilePicture,
  ) async {
    final db = await database;
    final count = await db.update(
      'users',
      {'profile_picture': profilePicture},
      where: 'email = ?',
      whereArgs: [email],
    );
    dev.debugPrint(
      'DatabaseHelper: Updated profile picture for email $email to $profilePicture, affected rows: $count',
    );
    return count;
  }

  Future<int> updateUserAccountType(String email, String accountType) async {
    final db = await database;
    final count = await db.update(
      'users',
      {'account_type': accountType},
      where: 'email = ?',
      whereArgs: [email],
    );
    dev.debugPrint(
      'DatabaseHelper: Updated account type for email $email to $accountType, affected rows: $count',
    );
    return count;
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password); // Hash the input password
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );
    dev.debugPrint(
      'DatabaseHelper: User query returned ${result.length} result(s) for email $email',
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    dev.debugPrint(
      'DatabaseHelper: getUserByEmail returned ${result.length} result(s) for email $email: $result',
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> queryUsers() async {
    final db = await database;
    try {
      final result = await db.query('users');
      dev.debugPrint(
        'DatabaseHelper: Retrieved ${result.length} users from database',
      );
      return result;
    } catch (e) {
      dev.debugPrint('DatabaseHelper: Error in queryUsers: $e');
      return [];
    }
  }

  Future<int> updateUser(String oldEmail, Map<String, dynamic> row) async {
    final db = await database;
    final count = await db.update(
      'users',
      row,
      where: 'email = ?',
      whereArgs: [oldEmail],
    );
    // If email changed, update related items and reports
    if (row['email'] != oldEmail) {
      await db.update(
        'items',
        {'uploader_email': row['email']},
        where: 'uploader_email = ?',
        whereArgs: [oldEmail],
      );
      await db.update(
        'reports',
        {'reporter_email': row['email']},
        where: 'reporter_email = ?',
        whereArgs: [oldEmail],
      );
    }
    dev.debugPrint(
      'DatabaseHelper: Updated $count user(s) with email $oldEmail',
    );
    return count;
  }

  Future<int> deleteUser(String email) async {
    final db = await database;
    // Delete related items and reports first
    await db.delete('items', where: 'uploader_email = ?', whereArgs: [email]);
    await db.delete('reports', where: 'reporter_email = ?', whereArgs: [email]);
    final count = await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    dev.debugPrint('DatabaseHelper: Deleted $count user(s) with email $email');
    return count;
  }

  Future<List<Map<String, dynamic>>> getAllReports() async {
    final db = await database;
    try {
      final result = await db.query('reports');
      dev.debugPrint(
        'DatabaseHelper: Retrieved ${result.length} reports from database',
      );
      return result;
    } catch (e) {
      dev.debugPrint('DatabaseHelper: Error in getAllReports: $e');
      return [];
    }
  }

  Future<int> insertReport(Map<String, dynamic> row) async {
    final db = await database;
    final id = await db.insert('reports', row);
    dev.debugPrint('DatabaseHelper: Inserted report with id $id');
    return id;
  }

  Future<int> updateReportStatus(int id, String status) async {
    final db = await database;
    final count = await db.update(
      'reports',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
    dev.debugPrint(
      'DatabaseHelper: Updated $count report(s) with id $id to status $status',
    );
    return count;
  }

  Future<int> deleteReport(int id) async {
    final db = await database;
    final count = await db.delete('reports', where: 'id = ?', whereArgs: [id]);
    dev.debugPrint('DatabaseHelper: Deleted $count report(s) with id $id');
    return count;
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split(' ')
        .map(
          (word) =>
              word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
