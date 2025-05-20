import 'package:drophope/main.dart';
import 'package:drophope/data/item_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        'ProfileScreen: Saving profile picture to: $profilePicturePath',
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
    final itemProvider = ItemProviderInherited.of(context);
    if (userState == null || itemProvider == null) {
      return const Scaffold(body: Center(child: Text("Error loading profile")));
    }

    final username = userState.username;
    final accountType = userState.accountType;
    final email = userState.email;
    final profilePicture = userState.profilePicture;
    final itemsPosted =
        itemProvider.items.where((item) => item.uploaderEmail == email).length;

    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5), // Lighter background
            BlendMode.dstATop,
          ),
          onError: (exception, stackTrace) {
            debugPrint('Error loading background image: $exception');
            debugPrint('Stack trace: $stackTrace');
          },
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("My Profile")),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Increased padding
            child: SingleChildScrollView(
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
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 40, // Slightly larger PFP
                                backgroundColor: Colors.grey[300],
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
                                          size: 45,
                                          color: Colors.black54,
                                        )
                                        : null,
                              ),
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
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20), // Increased spacing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient:
                                        accountType == "PRO"
                                            ? const LinearGradient(
                                              colors: [
                                                Color.fromARGB(
                                                  255,
                                                  62,
                                                  145,
                                                  227,
                                                ),
                                                Color.fromARGB(
                                                  255,
                                                  26,
                                                  215,
                                                  200,
                                                ),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                            : null,
                                    color:
                                        accountType == "PRO"
                                            ? null
                                            : Colors.blueGrey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    accountType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Account Type: $accountType",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40), // Increased spacing
                  Text(
                    "Stats",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: const Text(
                        "Items Posted",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "$itemsPosted",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Account Limitations",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: const Text(
                        "Free Items Per Month",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        accountType == "BASIC"
                            ? "Limited to 2 (Used: ${userState.freeItemsPostedThisMonth})"
                            : "Unlimited",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
