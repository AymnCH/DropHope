import 'package:collection/collection.dart';
import 'package:flutter/material.dart' as dev show debugPrint;
import 'package:drophope/data/item.dart';
import 'package:drophope/database_helper.dart';
import 'package:flutter/material.dart';

class ItemProviderNotifier extends ChangeNotifier {
  List<Item> _items = [];

  ItemProviderNotifier() {
    dev.debugPrint('ItemProviderNotifier: Initializing');
    _loadItems();
  }

  List<Item> get items => List.unmodifiable(_items);

  Future<void> _loadItems() async {
    dev.debugPrint('ItemProviderNotifier: Starting to load items');
    try {
      final itemMaps = await DatabaseHelper.instance.getAllItems();
      _items =
          itemMaps
              .map(
                (map) => Item(
                  id: map['id'],
                  title: map['title'],
                  description: map['description'],
                  type: map['type'],
                  category: map['category'],
                  imagePath: map['image_path'],
                  uploaderEmail: map['uploader_email'],
                  uploaderName: map['uploader_name'] ?? 'Unknown',
                  phone: map['phone'],
                ),
              )
              .toList();
      dev.debugPrint(
        'ItemProviderNotifier: Loaded ${_items.length} items: ${_items.map((i) => i.title).toList()}',
      );
    } catch (e) {
      dev.debugPrint('ItemProviderNotifier: Error loading items: $e');
      _items = [];
    }
    notifyListeners();
    dev.debugPrint(
      'ItemProviderNotifier: Notified listeners with ${_items.length} items',
    );
  }

  Future<void> addItem(Item item) async {
    try {
      await DatabaseHelper.instance.insertUser({
        'email': item.uploaderEmail,
        'full_name': item.uploaderName,
        'password': 'password123',
      });

      await DatabaseHelper.instance.insertItem({
        'title': item.title,
        'description': item.description,
        'type': item.type,
        'category': item.category,
        'image_path': item.imagePath,
        'uploader_email': item.uploaderEmail,
        'phone': item.phone,
      });
      dev.debugPrint('ItemProviderNotifier: Added item "${item.title}"');
    } catch (e) {
      dev.debugPrint('ItemProviderNotifier: Error adding item: $e');
    }
    await _loadItems();
  }

  Future<void> updateItem(int id, Item updatedItem) async {
    try {
      await DatabaseHelper.instance.insertUser({
        'email': updatedItem.uploaderEmail,
        'full_name': updatedItem.uploaderName,
        'password': 'password123',
      });

      await DatabaseHelper.instance.updateItem(id, {
        'title': updatedItem.title,
        'description': updatedItem.description,
        'type': updatedItem.type,
        'category': updatedItem.category,
        'image_path': updatedItem.imagePath,
        'uploader_email': updatedItem.uploaderEmail,
        'phone': updatedItem.phone,
      });
      dev.debugPrint(
        'ItemProviderNotifier: Updated item "${updatedItem.title}" with id $id',
      );
    } catch (e) {
      dev.debugPrint('ItemProviderNotifier: Error updating item: $e');
    }
    await _loadItems();
  }

  Future<void> deleteItem(int id) async {
    try {
      await DatabaseHelper.instance.deleteItem(id);
      dev.debugPrint('ItemProviderNotifier: Deleted item with id $id');
    } catch (e) {
      dev.debugPrint('ItemProviderNotifier: Error deleting item: $e');
    }
    await _loadItems();
  }
}

class ItemProviderInherited extends InheritedWidget {
  final ItemProviderNotifier provider;

  const ItemProviderInherited({
    super.key,
    required this.provider,
    required super.child,
  });

  @override
  bool updateShouldNotify(ItemProviderInherited oldWidget) {
    return !const DeepCollectionEquality().equals(
      provider.items,
      oldWidget.provider.items,
    );
  }

  static ItemProviderNotifier? of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<ItemProviderInherited>();
    return inherited?.provider;
  }
}
