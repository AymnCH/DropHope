import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  Widget? buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _CommunityScreenState? state = _CommunityScreenState._instance;
        if (state != null) {
          state._showAddPostDialog();
        }
      },
      backgroundColor: Colors.indigo,
      child: const Icon(Icons.add),
    );
  }

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  static _CommunityScreenState? _instance;

  int _selectedTab = 0;
  final List<Map<String, dynamic>> _posts = [
    {
      "username": "Aya",
      "time": "40 minutes ago",
      "content":
          "I went to this community event yesterday and it was magnificent...",
      "image": "assets/items_images/event.png",
      "comments": 4,
      "likes": 7,
    },
    {
      "username": "Aymen",

      "time": "2 hours ago",
      "content":
          "I liked the way they organized the event, it was very informative.",
      "image": 'assets/items_images/codingevent.jpg',
      "comments": 0,
      "likes": 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _instance = this;
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  void _addNewPost(String content, String? imagePath) {
    setState(() {
      _posts.insert(0, {
        "username": "You",
        "time": "Just now",
        "content": content,
        "image": imagePath,
        "comments": 0,
        "likes": 0,
      });
    });
  }

  void _showAddPostDialog() {
    String content = '';
    String? imagePath;
    File? imageFile; // Store the selected image file for preview
    bool imageSelected = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Create a Post"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "What's on your mind?",
                      ),
                      onChanged: (value) {
                        content = value;
                      },
                      maxLines: 3,
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
                          debugPrint('Error loading uploaded image: $error');
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
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (content.isNotEmpty) {
                      _addNewPost(content, imagePath);
                      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTabButton("Posts", 0),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTab = 1;
                  });
                },
                child: const Row(
                  children: [
                    Text("View FAQs", style: TextStyle(color: Colors.indigo)),
                    SizedBox(width: 4),
                    Icon(Icons.help_outline, color: Colors.indigo),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButton<String>(
            value: 'Category',
            items: const [
              DropdownMenuItem(value: 'Category', child: Text('Category')),
            ],
            onChanged: (value) {},
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down),
          ),
        ),
        Expanded(child: _selectedTab == 0 ? _buildPostsTab() : _buildFAQsTab()),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedTab == index ? Colors.indigo : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedTab == index ? Colors.indigo : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${post['username']} posted",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            post['time'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.flag_outlined, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(post['content']),
                if (post['image'] != null) ...[
                  const SizedBox(height: 8),
                  post['image'].startsWith('assets/')
                      ? Image.asset(
                        post['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading post image: $error');
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text("Image Not Available"),
                            ),
                          );
                        },
                      )
                      : Image.file(
                        File(post['image']),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading post image: $error');
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text("Image Not Available"),
                            ),
                          );
                        },
                      ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.comment, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${post['comments']} comments"),
                    const SizedBox(width: 16),
                    const Icon(Icons.favorite, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${post['likes']} likes"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAQsTab() {
    return const Center(
      child: Text(
        "No FAQs yet",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
