import 'package:drophope/data/item.dart';
import 'package:drophope/data/item_provider.dart';
import 'package:drophope/screens/user_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  void _showEditDialog(Item item) {
    String title = item.title;
    String description = item.description;
    String phone = item.phone ?? '';
    String? imagePath = item.imagePath;
    File? imageFile;
    bool imageSelected = imagePath != null;
    String selectedCategory = item.category;
    String fullName = item.uploaderName;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Post"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: "Title"),
                      controller: TextEditingController(text: title),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items:
                          (item.type == "Free"
                                  ? ['Free food', 'Free items']
                                  : item.type == "Cheap"
                                  ? ['For sale']
                                  : item.type == "Rent"
                                  ? ['Rent']
                                  : item.type == "Wanted"
                                  ? ['Wanted']
                                  : ['Forum'])
                              .map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              })
                              .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                      isExpanded: true,
                      hint: const Text("Select Category"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      controller: TextEditingController(text: description),
                      onChanged: (value) {
                        description = value;
                      },
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(labelText: "Full Name"),
                      controller: TextEditingController(text: fullName),
                      onChanged: (value) {
                        fullName = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Phone Number (Optional)",
                      ),
                      controller: TextEditingController(text: phone),
                      onChanged: (value) {
                        phone = value;
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setDialogState(() {
                            imageFile = File(pickedFile.path);
                            imagePath = pickedFile.path;
                            imageSelected = true;
                          });
                        }
                      },
                      child: const Text("Change Photo"),
                    ),
                    if (imageSelected &&
                        (imageFile != null || imagePath != null)) ...[
                      const SizedBox(height: 10),
                      imageFile != null
                          ? Image.file(
                            imageFile!,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text(
                                "Image Preview Not Available",
                                style: TextStyle(color: Colors.grey),
                              );
                            },
                          )
                          : imagePath!.startsWith('assets/')
                          ? Image.asset(
                            imagePath!,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text(
                                "Image Preview Not Available",
                                style: TextStyle(color: Colors.grey),
                              );
                            },
                          )
                          : Image.file(
                            File(imagePath!),
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text(
                                "Image Preview Not Available",
                                style: TextStyle(color: Colors.grey),
                              );
                            },
                          ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (title.isNotEmpty && description.isNotEmpty) {
                      final updatedItem = Item(
                        id: item.id,
                        title: title,
                        description: description,
                        type: item.type,
                        category: selectedCategory,
                        imagePath: imagePath,
                        uploaderEmail: item.uploaderEmail,
                        uploaderName:
                            fullName.isNotEmpty ? fullName : item.uploaderName,
                        phone: phone.isNotEmpty ? phone : "N/A",
                      );
                      final provider = ItemProviderInherited.of(context);
                      if (provider != null && item.id != null) {
                        provider.updateItem(item.id!, updatedItem);
                      }
                      Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Title and description are required'),
                        ),
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = ItemProviderInherited.of(context);
    final userProvider = UserProvider.of(context);

    if (itemProvider == null || userProvider == null) {
      debugPrint('ListingScreen: Provider or UserProvider is null');
      return const Scaffold(body: Center(child: Text('Provider not found')));
    }

    return ListenableBuilder(
      listenable: itemProvider,
      builder: (context, _) {
        final userItems =
            itemProvider.items
                .where((item) => item.uploaderEmail == userProvider.email)
                .toList();
        debugPrint(
          'ListingScreen: User email: ${userProvider.email}, Total items: ${itemProvider.items.length}, User items: ${userItems.length}, Titles: ${userItems.map((i) => i.title).toList()}',
        );

        return Scaffold(
          appBar: AppBar(title: const Text('My Listings')),
          body:
              userItems.isEmpty
                  ? const Center(child: Text('No listings found'))
                  : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: userItems.length,
                    itemBuilder: (context, index) {
                      final item = userItems[index];
                      debugPrint(
                        'ListingScreen: Displaying item ${item.title}, uploaderEmail: ${item.uploaderEmail}',
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading:
                              item.imagePath != null
                                  ? item.imagePath!.startsWith('assets/')
                                      ? Image.asset(
                                        item.imagePath!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          debugPrint(
                                            'Error loading image: $error',
                                          );
                                          return const Icon(
                                            Icons.image_not_supported,
                                          );
                                        },
                                      )
                                      : Image.file(
                                        File(item.imagePath!),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          debugPrint(
                                            'Error loading image: $error',
                                          );
                                          return const Icon(
                                            Icons.image_not_supported,
                                          );
                                        },
                                      )
                                  : const Icon(Icons.image_not_supported),
                          title: Text(item.title),
                          subtitle: Text(item.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditDialog(item);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  if (item.id != null) {
                                    itemProvider.deleteItem(item.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }
}
