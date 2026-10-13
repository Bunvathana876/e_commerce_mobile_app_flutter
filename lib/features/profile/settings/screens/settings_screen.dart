import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/bouncing_button.dart';
import '../providers/theme_provider.dart';

// Settings screen for managing theme, notifications, language, and currency.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local settings form state
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD (\$)';
  bool _orderNotifications = true;
  bool _promoNotifications = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image with dark mode dimming
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_all_screens.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          if (isDark)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.65,
                ), // Dim background in Dark Mode
              ),
            ),

          // Settings content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                // Top Custom App Bar
                Row(
                  children: [
                    BouncingButton(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBg.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: titleColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Appearance and display
                _buildSectionTitle('Appearance', titleColor),
                const SizedBox(height: 8),
                _buildCardGroup(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  children: [
                    // Dark Mode Toggle
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? const Color(0xFF818CF8)
                                      : const Color(0xFF3B82F6))
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: isDark
                              ? const Color(0xFF818CF8)
                              : const Color(0xFF3B82F6),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        'Dark Theme',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      subtitle: Text(
                        isDark ? 'Dark mode enabled' : 'Light mode enabled',
                        style: TextStyle(fontSize: 12, color: subColor),
                      ),
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeTrackColor: const Color(0xFF1E88E5),
                        onChanged: (val) => themeProvider.toggleTheme(val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Regional and currency
                _buildSectionTitle('Regional & Currency', titleColor),
                const SizedBox(height: 8),
                _buildCardGroup(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  children: [
                    // Language
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: Color(0xFF10B981),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: _selectedLanguage,
                        dropdownColor: cardBg,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        items: const [
                          DropdownMenuItem(
                            value: 'English',
                            child: Text('English 🇺🇸'),
                          ),
                          DropdownMenuItem(
                            value: 'Khmer',
                            child: Text('ភាសាខ្មែរ 🇰🇭'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedLanguage = val);
                          }
                        },
                      ),
                    ),
                    Divider(height: 1, indent: 56, color: borderColor),

                    // Currency
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.attach_money_rounded,
                          color: Color(0xFFF59E0B),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        'Currency',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: _selectedCurrency,
                        dropdownColor: cardBg,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        items: const [
                          DropdownMenuItem(
                            value: 'USD (\$)',
                            child: Text('USD (\$)'),
                          ),
                          DropdownMenuItem(
                            value: 'KHR (៛)',
                            child: Text('KHR (៛)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCurrency = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Notification preferences
                _buildSectionTitle('Notifications', titleColor),
                const SizedBox(height: 8),
                _buildCardGroup(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      title: Text(
                        'Order Updates',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      subtitle: Text(
                        'Tracking and delivery alerts',
                        style: TextStyle(fontSize: 12, color: subColor),
                      ),
                      value: _orderNotifications,
                      activeTrackColor: const Color(0xFF1E88E5),
                      onChanged: (val) =>
                          setState(() => _orderNotifications = val),
                    ),
                    Divider(height: 1, indent: 16, color: borderColor),
                    SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      title: Text(
                        'Discounts & Deals',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      subtitle: Text(
                        'Promotions and flash sales',
                        style: TextStyle(fontSize: 12, color: subColor),
                      ),
                      value: _promoNotifications,
                      activeTrackColor: const Color(0xFF1E88E5),
                      onChanged: (val) =>
                          setState(() => _promoNotifications = val),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Storage and cache
                _buildSectionTitle('Storage & Cache', titleColor),
                const SizedBox(height: 8),
                _buildCardGroup(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFEF4444,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.cleaning_services_rounded,
                          color: Color(0xFFEF4444),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        'Clear Image Cache',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      subtitle: Text(
                        'Free up temporary app storage (~18 MB)',
                        style: TextStyle(fontSize: 12, color: subColor),
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Image cache cleared successfully!',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
    );
  }

  Widget _buildCardGroup({
    required Color cardBg,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
