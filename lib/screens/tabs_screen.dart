import 'package:drophope/data/item.dart';
import 'package:drophope/data/item_provider.dart';
import 'package:drophope/main.dart';
import 'package:drophope/screens/community_screen.dart';
import 'package:drophope/screens/explore_screen.dart';
import 'package:drophope/screens/home_screen.dart';
import 'package:drophope/screens/listing_screen.dart';
import 'package:drophope/screens/edit_profile_screen.dart';
import 'package:drophope/screens/login_screen.dart';
import 'package:drophope/screens/messages_screen.dart';
import 'package:drophope/screens/security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:drophope/database_helper.dart'; // Import DatabaseHelper for reports

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;
  late final ItemProviderNotifier _itemProviderNotifier;
  late final List<List<Widget>> _screenStacks;
  final GlobalKey<MessagesScreenState> _messagesScreenKey =
      GlobalKey<MessagesScreenState>();

  @override
  void initState() {
    super.initState();
    _itemProviderNotifier = ItemProviderNotifier();
    _screenStacks = [
      [
        HomeScreen(
          navigateToScreen: _navigateToScreen,
          navigateToScreenAndSwitchTab: _navigateToScreenAndSwitchTab,
        ),
      ],
      [
        ExploreScreen(
          navigateToScreen: _navigateToScreen,
          navigateToScreenAndSwitchTab: _navigateToScreenAndSwitchTab,
        ),
      ],
      [],
      [const CommunityScreen()],
      [
        MessagesScreen(
          navigateToScreen: _navigateToScreen,
          key: _messagesScreenKey,
        ),
      ],
    ];
  }

  void _addNewItem(
    String title,
    String description,
    String type,
    String category,
    String? imagePath,
    String uploaderEmail,
    String uploaderName,
    String? phone,
  ) {
    final userState = userStateKey.currentState;
    if (userState == null || userState.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add an item')),
      );
      return;
    }

    final effectiveUploaderName =
        uploaderName.isNotEmpty
            ? uploaderName
            : userState.username.isNotEmpty
            ? userState.username
            : userState.email!.split('@')[0].replaceAll('.', ' ');

    final item = Item(
      title: title,
      description: description,
      type: type,
      category: category,
      imagePath: imagePath,
      uploaderEmail: uploaderEmail,
      uploaderName: effectiveUploaderName,
      phone: phone ?? "N/A",
    );
    _itemProviderNotifier.addItem(item);
  }

  void _showAddOptionsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionRow(
                icon: Icons.apple,
                color: Colors.indigo,
                label: "Free",
                description: "Give away free food/non-food",
                onTap: () {
                  Navigator.of(context).pop();
                  _showPostDialog("Free");
                },
              ),
              const Divider(),
              _buildOptionRow(
                icon: Icons.sell,
                color: Colors.pink[300]!,
                label: "Sell",
                description: "Sell non-food items",
                onTap: () {
                  Navigator.of(context).pop();
                  _showPostDialog("Cheap");
                },
              ),
              const Divider(),
              _buildOptionRow(
                icon: Icons.swap_horiz,
                color: Colors.orange[700]!,
                label: "Rent",
                description: "Rent your things to people locally",
                onTap: () {
                  Navigator.of(context).pop();
                  _showPostDialog("Rent");
                },
              ),
              const Divider(),
              _buildOptionRow(
                icon: Icons.mic,
                color: Colors.yellow[700]!,
                label: "Wanted",
                description: "Ask for something",
                onTap: () {
                  Navigator.of(context).pop();
                  _showPostDialog("Wanted");
                },
              ),
              const Divider(),
              _buildOptionRow(
                icon: Icons.forum,
                color: Colors.pink[300]!,
                label: "Forum",
                description: "Share relevant topics with the community",
                onTap: () {
                  Navigator.of(context).pop();
                  _showPostDialog("Forum");
                },
              ),
              const Divider(),
              _buildOptionRow(
                icon: Icons.help,
                color: Colors.yellow[700]!,
                label: "Help! What can I add?",
                description: "",
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help screen not implemented yet'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPostDialog(String type) {
    String title = '';
    String description = '';
    String phone = '';
    String? imagePath;
    File? imageFile;
    bool imageSelected = false;
    String selectedCategory =
        type == "Free"
            ? "Free food"
            : type == "Cheap"
            ? "For sale"
            : type == "Rent"
            ? "Rent"
            : type == "Wanted"
            ? "Wanted"
            : "Forum";
    String fullName = '';

    final userState = userStateKey.currentState;
    final defaultFullName =
        userState?.username.isNotEmpty == true
            ? userState!.username
            : userState?.email?.split('@')[0].replaceAll('.', ' ') ?? 'Unknown';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text("Post a $type Item"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: "Title"),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items:
                          (type == "Free"
                                  ? ['Free food', 'Free items']
                                  : type == "Cheap"
                                  ? ['For sale']
                                  : type == "Rent"
                                  ? ['Rent']
                                  : type == "Wanted"
                                  ? ['Wanted']
                                  : ['Forum'])
                              .map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
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
                      onChanged: (value) {
                        description = value;
                      },
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        hintText: defaultFullName,
                      ),
                      onChanged: (value) {
                        fullName = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Phone Number (Optional)",
                      ),
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
                      child: const Text("Upload Photo"),
                    ),
                    if (imageSelected && imageFile != null) ...[
                      const SizedBox(height: 10),
                      Image.file(
                        imageFile!,
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
                      final userState = userStateKey.currentState;
                      if (userState == null || userState.email == null) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'User email is required to post an item',
                            ),
                          ),
                        );
                        return;
                      }
                      _addNewItem(
                        title,
                        description,
                        type,
                        selectedCategory,
                        imagePath,
                        userState.email!,
                        fullName.isNotEmpty ? fullName : defaultFullName,
                        phone.isNotEmpty ? phone : "N/A",
                      );
                      Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Title and description are required'),
                        ),
                      );
                    }
                  },
                  child: const Text("Post"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // New method to show the report dialog
  void _showReportDialog(BuildContext dialogContext, Item item) {
    String reportDetails = '';
    final userState = userStateKey.currentState;

    if (userState == null || userState.email == null) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        const SnackBar(content: Text('Please log in to report an item')),
      );
      return;
    }

    showDialog(
      context: dialogContext,
      builder: (reportDialogContext) {
        return AlertDialog(
          title: const Text("Report Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Reason for Reporting",
                    hintText: "Describe the issue with this item",
                  ),
                  onChanged: (value) {
                    reportDetails = value;
                  },
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(reportDialogContext).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (reportDetails.isNotEmpty) {
                  final dbHelper = DatabaseHelper.instance;
                  await dbHelper.insertReport({
                    'item_id': item.id,
                    'reporter_email': userState.email!,
                    'report_details': reportDetails,
                    'timestamp': DateTime.now().toIso8601String(),
                  });
                  Navigator.of(reportDialogContext).pop();
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted successfully'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(reportDialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for reporting'),
                    ),
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

  Widget _buildOptionRow({
    required IconData icon,
    required Color color,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha((0.2 * 255).toInt()),
        child: Icon(icon, color: color),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: description.isNotEmpty ? Text(description) : null,
      onTap: onTap,
    );
  }

  void _navigateToScreen(Widget screen) {
    setState(() {
      _screenStacks[_selectedIndex].add(screen);
    });
  }

  void _navigateToScreenAndSwitchTab(Widget screen, int targetTabIndex) {
    setState(() {
      _screenStacks[_selectedIndex] = _initializeStack(_selectedIndex);
      _selectedIndex = targetTabIndex;
      _screenStacks[_selectedIndex] = _initializeStack(_selectedIndex);

      if (targetTabIndex == 4 &&
          screen is MessagesScreen &&
          screen.startNewConversationWith != null) {
        final messagesScreen =
            _screenStacks[_selectedIndex].firstWhere(
                  (s) => s is MessagesScreen,
                  orElse:
                      () => MessagesScreen(
                        navigateToScreen: _navigateToScreen,
                        key: _messagesScreenKey,
                      ),
                )
                as MessagesScreen;

        _screenStacks[_selectedIndex] = [messagesScreen];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final messagesScreenState = _messagesScreenKey.currentState;
          if (messagesScreenState != null) {
            messagesScreenState.startNewConversation(
              screen.startNewConversationWith!,
            );
          }
        });
      } else if (screen.runtimeType !=
          _screenStacks[_selectedIndex].first.runtimeType) {
        _screenStacks[_selectedIndex].add(screen);
      }
    });
  }

  void _navigateFromDrawer(Widget screen, int targetTabIndex) {
    setState(() {
      _screenStacks[_selectedIndex] = _initializeStack(_selectedIndex);
      _selectedIndex = targetTabIndex;
      _screenStacks[_selectedIndex] = _initializeStack(_selectedIndex);
      if (screen.runtimeType !=
          _screenStacks[_selectedIndex].first.runtimeType) {
        _screenStacks[_selectedIndex].add(screen);
      }
    });
  }

  void _goBack() {
    if (_screenStacks[_selectedIndex].length > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _screenStacks[_selectedIndex].removeLast();
        });
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddOptionsDialog();
      return;
    }
    setState(() {
      _selectedIndex = index;
      _screenStacks[_selectedIndex] = _initializeStack(_selectedIndex);
    });
  }

  List<Widget> _initializeStack(int index) {
    switch (index) {
      case 0:
        return [
          HomeScreen(
            navigateToScreen: _navigateToScreen,
            navigateToScreenAndSwitchTab: _navigateToScreenAndSwitchTab,
          ),
        ];
      case 1:
        return [
          ExploreScreen(
            navigateToScreen: _navigateToScreen,
            navigateToScreenAndSwitchTab: _navigateToScreenAndSwitchTab,
          ),
        ];
      case 2:
        return [];
      case 3:
        return [const CommunityScreen()];
      case 4:
        return [
          MessagesScreen(
            navigateToScreen: _navigateToScreen,
            key: _messagesScreenKey,
          ),
        ];
      default:
        return [];
    }
  }

  Widget? _getFloatingActionButton() {
    final currentScreen = _screenStacks[_selectedIndex].last;
    if (currentScreen is CommunityScreen) {
      return currentScreen.buildFloatingActionButton();
    }
    return null;
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final index = _selectedIndex;
    if (settings.name == '/' || settings.name == null) {
      final initialScreen = _initializeStack(index).first;
      return MaterialPageRoute(builder: (_) => initialScreen);
    }
    return MaterialPageRoute(
      builder:
          (_) => const Scaffold(body: Center(child: Text('Route not found'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ItemProviderInherited(
      provider: _itemProviderNotifier,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Image.asset(
            'assets/images/appbar.png',
            height: 40.h,
            fit: BoxFit.contain,
            width: 150.w,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
            Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 130.h,
                color: Colors.indigo[50],
                child: Center(
                  child: Image.asset(
                    'assets/images/appbar.png',
                    height: 40.h,
                    fit: BoxFit.contain,
                    width: 150.w,
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.list_sharp,
                title: 'My listings',
                onTap: () {
                  Navigator.pop(context);
                  _navigateFromDrawer(const ListingScreen(), _selectedIndex);
                },
              ),
              _buildDrawerItem(
                icon: Icons.edit,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.pop(context);
                  _navigateFromDrawer(
                    const EditProfileScreen(),
                    _selectedIndex,
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.security,
                title: 'Security',
                onTap: () {
                  Navigator.pop(context);
                  _navigateFromDrawer(const SecurityScreen(), _selectedIndex);
                },
              ),
              _buildDrawerItem(
                icon: Icons.color_lens,
                title: 'Appearance',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appearance screen not implemented yet'),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Sign out',
                color: Colors.red,
                showTrailing: false,
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 20, 12, 70),
                          ),
                        ),
                        content: const Text(
                          'Are you sure you want to sign out?',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: PopScope(
            canPop: _screenStacks[_selectedIndex].length <= 1,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                _goBack();
              }
            },
            child: IndexedStack(
              index: _selectedIndex,
              children:
                  _screenStacks.map((stack) {
                    return Navigator(
                      onGenerateRoute: _generateRoute,
                      onDidRemovePage: (page) {
                        _goBack();
                      },
                      pages:
                          stack.isEmpty
                              ? [
                                const MaterialPage(
                                  child: Scaffold(
                                    body: Center(child: Text('Empty Stack')),
                                  ),
                                ),
                              ]
                              : stack
                                  .map((screen) => MaterialPage(child: screen))
                                  .toList(),
                    );
                  }).toList(),
            ),
          ),
        ),
        floatingActionButton: _getFloatingActionButton(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 27,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromRGBO(7, 134, 203, 1),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 31),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(246, 131, 42, 1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
              label: 'Add',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.forum_outlined),
              label: 'Community',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined),
              label: 'Messages',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black,
    bool showTrailing = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: color, size: 30),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          color: color,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
      trailing:
          showTrailing ? const Icon(Icons.arrow_forward_ios, size: 19) : null,
      onTap: onTap,
    );
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
