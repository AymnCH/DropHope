import 'package:drophope/main.dart';
import 'package:drophope/screens/user_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  Future<void> _changeProfilePicture(BuildContext context) async {
    final userState = userStateKey.currentState;
    if (userState == null || userState.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to change profile picture'),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final profilePicturesDir = Directory('${appDir.path}/profile_pictures');
      if (!await profilePicturesDir.exists()) {
        await profilePicturesDir.create(recursive: true);
      }
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(
        pickedFile.path,
      ).copy('${profilePicturesDir.path}/$fileName');
      final profilePicturePath = savedImage.path;

      debugPrint(
        'AdminProfileScreen: Saving profile picture to: $profilePicturePath',
      );
      await userState.updateProfile(profilePicture: profilePicturePath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = userStateKey.currentState;
    final userProvider = UserProvider.of(context);
    if (userState == null || userProvider == null) {
      return const Scaffold(body: Center(child: Text("Error loading profile")));
    }

    final username = userProvider.username;
    final email = userProvider.email ?? "Not provided";
    final role = userProvider.role ?? "Admin";
    final profilePicture = userProvider.profilePicture;

    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("My Profile")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _changeProfilePicture(context),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              profilePicture != null &&
                                      File(profilePicture).existsSync()
                                  ? FileImage(File(profilePicture))
                                  : null,
                          child:
                              profilePicture == null ||
                                      !File(profilePicture).existsSync()
                                  ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.black,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.indigo,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 62, 145, 227),
                                  Color.fromARGB(255, 26, 215, 200),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Email: $email",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Stats",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: const Text("Reports Managed"),
                  subtitle: const Text(
                    "N/A",
                  ), // Placeholder; requires admin report data
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Account Limitations",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: const Text("Report Actions Per Day"),
                  subtitle: const Text(
                    "Limited to 50",
                  ), // Placeholder; adjust based on needs
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
