import 'package:drophope/screens/category_screen.dart';
import 'package:drophope/screens/upgrade_pro_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Function(Widget) navigateToScreen;
  final Function(Widget, int) navigateToScreenAndSwitchTab;

  const HomeScreen({
    super.key,
    this.navigateToScreen = _defaultNavigate,
    this.navigateToScreenAndSwitchTab = _defaultNavigateAndSwitchTab,
  });

  static void _defaultNavigate(Widget screen) {}
  static void _defaultNavigateAndSwitchTab(Widget screen, int tabIndex) {}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 5),
                  const Row(
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        ' Would you be interested in supporting the platform\n and enjoying advanced features?',
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          elevation: WidgetStateProperty.all(0),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        onPressed: () {
                          navigateToScreen(const UpgradeProScreen());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 62, 145, 227),
                                Color.fromARGB(255, 26, 215, 200),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 11,
                          ),
                          child: const Text(
                            'Go PRO for more benefits!',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildCategoryButton(
                    icon: Icons.apple,
                    color: Colors.indigo,
                    label: "Free food",
                    onTap: () {
                      navigateToScreen(
                        CategoryScreen(
                          category: "Free food",
                          navigateToScreen: navigateToScreen,
                          navigateToScreenAndSwitchTab:
                              navigateToScreenAndSwitchTab,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCategoryButton(
                    icon: Icons.local_offer,
                    color: Colors.indigo[100]!,
                    label: "Free items",
                    onTap: () {
                      navigateToScreen(
                        CategoryScreen(
                          category: "Free items",
                          navigateToScreen: navigateToScreen,
                          navigateToScreenAndSwitchTab:
                              navigateToScreenAndSwitchTab,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildCategoryButton(
                    icon: Icons.sell,
                    color: Colors.pink[300]!,
                    label: "For sale",
                    onTap: () {
                      navigateToScreen(
                        CategoryScreen(
                          category: "For sale",
                          navigateToScreen: navigateToScreen,
                          navigateToScreenAndSwitchTab:
                              navigateToScreenAndSwitchTab,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCategoryButton(
                    icon: Icons.swap_horiz,
                    color: Colors.pink[100]!,
                    label: "Rent",
                    onTap: () {
                      navigateToScreen(
                        CategoryScreen(
                          category: "Rent",
                          navigateToScreen: navigateToScreen,
                          navigateToScreenAndSwitchTab:
                              navigateToScreenAndSwitchTab,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildCategoryButton(
                    icon: Icons.mic,
                    color: Colors.yellow[700]!,
                    label: "Wanted",
                    onTap: () {
                      navigateToScreen(
                        CategoryScreen(
                          category: "Wanted",
                          navigateToScreen: navigateToScreen,
                          navigateToScreenAndSwitchTab:
                              navigateToScreenAndSwitchTab,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCategoryButton(
                    icon: Icons.forum,
                    color: Colors.orange[300]!,
                    label: "Forum",
                    onTap: () {
                      navigateToScreen(
                        CategoryScreen(
                          category: "Forum",
                          navigateToScreen: navigateToScreen,
                          navigateToScreenAndSwitchTab:
                              navigateToScreenAndSwitchTab,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
