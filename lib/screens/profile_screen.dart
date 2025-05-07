import 'package:drophope/data/item_provider.dart';
import 'package:drophope/screens/user_provider.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = UserProvider.of(context);
    final itemProvider = ItemProviderInherited.of(context);
    if (userProvider == null || itemProvider == null) {
      return const Scaffold(body: Center(child: Text("Error loading profile")));
    }

    final username = userProvider.username;
    final accountType = userProvider.accountType;
    final email = userProvider.email;
    final itemsPosted =
        itemProvider.items.where((item) => item.uploaderEmail == email).length;

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
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
                            color:
                                accountType == "PRO"
                                    ? Colors.green
                                    : Colors.blue,
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
                    const SizedBox(height: 8),
                    Text(
                      "Account Type: $accountType",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Stats",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text("Items Posted"),
                subtitle: Text("$itemsPosted"),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Account Limitations",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text("Free Items Per Month"),
                subtitle: Text(
                  accountType == "Normal"
                      ? "Limited to 2 (Used: ${userProvider.freeItemsPostedThisMonth})"
                      : "Unlimited",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
