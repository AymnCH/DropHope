import 'package:drophope/data/item.dart';
import 'package:drophope/data/item_provider.dart';
import 'package:drophope/screens/admin_screens/report.dart';
import 'package:drophope/screens/admin_screens/report_provider.dart';
import 'package:drophope/screens/messages_screen.dart';
import 'package:drophope/screens/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class CategoryScreen extends StatefulWidget {
  final String category;
  final Function(Widget) navigateToScreen;
  final Function(Widget, int) navigateToScreenAndSwitchTab;

  const CategoryScreen({
    super.key,
    required this.category,
    this.navigateToScreen = _defaultNavigate,
    this.navigateToScreenAndSwitchTab = _defaultNavigateAndSwitchTab,
  });

  static void _defaultNavigate(Widget screen) {}
  static void _defaultNavigateAndSwitchTab(Widget screen, int tabIndex) {}

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  void _showFullImage(BuildContext context, String? imagePath) {
    if (imagePath == null) return;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imagePath.startsWith('assets/')
                  ? FutureBuilder(
                    future: precacheImage(AssetImage(imagePath), dialogContext),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.error != null) {
                        debugPrint('Error preloading image: ${snapshot.error}');
                        return const Icon(Icons.image_not_supported, size: 200);
                      }
                      return Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image in dialog: $error');
                          return const Icon(
                            Icons.image_not_supported,
                            size: 200,
                          );
                        },
                      );
                    },
                  )
                  : Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading image in dialog: $error');
                      return const Icon(Icons.image_not_supported, size: 200);
                    },
                  ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

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

  void _showReportDialog(Item item, String reporterEmail) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Report Item"),
          content: SizedBox(
            width: 400, // Increased width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Item: ${item.title}"),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: "Reason for Reporting",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5, // Increased height of TextField
                ),
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
                if (reasonController.text.isNotEmpty) {
                  final report = Report(
                    reporterEmail: reporterEmail,
                    itemId: item.id!,
                    reason: reasonController.text,
                  );
                  Provider.of<ReportProvider>(
                    context,
                    listen: false,
                  ).addReport(report);
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Report submitted")),
                  );
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text("Please provide a reason")),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ItemProviderInherited.of(context);
    final userProvider = UserProvider.of(context);
    debugPrint(
      'CategoryScreen: Provider fetched, instance: $provider, items: ${provider?.items.length ?? 0}, user email: ${userProvider?.email}',
    );
    if (provider == null || userProvider == null) {
      return const Scaffold(body: Center(child: Text("Error loading items")));
    }

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        debugPrint(
          'CategoryScreen: ListenableBuilder rebuilding with ${provider.items.length} items',
        );
        final filteredItems =
            provider.items
                .where((item) => item.category == widget.category)
                .toList();

        return DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), // Semi-transparent overlay
                BlendMode.dstATop,
              ),
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.category),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body:
                filteredItems.isEmpty
                    ? const Center(
                      child: Text(
                        "No items in this category",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isOwnItem =
                            item.uploaderEmail == userProvider.email;
                        debugPrint(
                          'CategoryScreen: Item ${item.title}, uploaderEmail: ${item.uploaderEmail}, userEmail: ${userProvider.email}, isOwnItem: $isOwnItem',
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
                                            return const Icon(
                                              Icons.image_not_supported,
                                            );
                                          },
                                        )
                                    : const Icon(Icons.image_not_supported),
                            title: Text(item.title),
                            subtitle: Text(item.description),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    titlePadding: const EdgeInsets.fromLTRB(
                                      24,
                                      24,
                                      24,
                                      0,
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (!isOwnItem)
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (userProvider.email == null) {
                                                ScaffoldMessenger.of(
                                                  dialogContext,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Please log in to report an item',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              Navigator.of(dialogContext).pop();
                                              _showReportDialog(
                                                item,
                                                userProvider.email!,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.report,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Report',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              minimumSize: const Size(0, 0),
                                            ),
                                          ),
                                      ],
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          item.imagePath != null
                                              ? GestureDetector(
                                                onTap:
                                                    () => _showFullImage(
                                                      dialogContext,
                                                      item.imagePath,
                                                    ),
                                                child:
                                                    item.imagePath!.startsWith(
                                                          'assets/',
                                                        )
                                                        ? FutureBuilder(
                                                          future: precacheImage(
                                                            AssetImage(
                                                              item.imagePath!,
                                                            ),
                                                            dialogContext,
                                                          ),
                                                          builder: (
                                                            context,
                                                            snapshot,
                                                          ) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return const SizedBox(
                                                                height: 100,
                                                                width: 100,
                                                                child: Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                ),
                                                              );
                                                            }
                                                            if (snapshot
                                                                    .error !=
                                                                null) {
                                                              debugPrint(
                                                                'Error preloading image: ${snapshot.error}',
                                                              );
                                                              return const Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                size: 100,
                                                              );
                                                            }
                                                            return ConstrainedBox(
                                                              constraints:
                                                                  const BoxConstraints(
                                                                    maxWidth:
                                                                        300,
                                                                    maxHeight:
                                                                        100,
                                                                  ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8.0,
                                                                    ),
                                                                child: Image.asset(
                                                                  item.imagePath!,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                  errorBuilder: (
                                                                    context,
                                                                    error,
                                                                    stackTrace,
                                                                  ) {
                                                                    debugPrint(
                                                                      'Error loading image in dialog: $error',
                                                                    );
                                                                    return const Icon(
                                                                      Icons
                                                                          .image_not_supported,
                                                                      size: 100,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        )
                                                        : Image.file(
                                                          File(item.imagePath!),
                                                          fit: BoxFit.cover,
                                                          height: 100,
                                                          width: 300,
                                                          errorBuilder: (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            debugPrint(
                                                              'Error loading image in dialog: $error',
                                                            );
                                                            return const Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                              size: 100,
                                                            );
                                                          },
                                                        ),
                                              )
                                              : const Icon(
                                                Icons.image_not_supported,
                                                size: 100,
                                              ),
                                          const SizedBox(height: 16),
                                          Text(item.description),
                                          const SizedBox(height: 16),
                                          Text(
                                            "Uploaded by: ${item.uploaderName}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Type: ${item.type}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Phone: ${item.phone ?? 'N/A'}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (!isOwnItem) ...[
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final phone =
                                                        item.phone ??
                                                        '1234567890';
                                                    final uri = Uri.parse(
                                                      'tel:$phone',
                                                    );
                                                    if (await canLaunchUrl(
                                                      uri,
                                                    )) {
                                                      await launchUrl(uri);
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        dialogContext,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Could not launch phone call',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(Icons.phone),
                                                  label: const Text('Call'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      dialogContext,
                                                    ).pop();
                                                    widget.navigateToScreenAndSwitchTab(
                                                      MessagesScreen(
                                                        startNewConversationWith:
                                                            item.uploaderName,
                                                      ),
                                                      4,
                                                    );
                                                  },
                                                  icon: const Icon(Icons.chat),
                                                  label: const Text('Chat'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.indigo,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                ),
                                              ],
                                              if (isOwnItem)
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      dialogContext,
                                                    ).pop();
                                                    _showEditDialog(item);
                                                  },
                                                  icon: const Icon(Icons.edit),
                                                  label: const Text(
                                                    'Edit Post',
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          debugPrint('Close button pressed');
                                          Navigator.of(dialogContext).pop();
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        );
      },
    );
  }
}
