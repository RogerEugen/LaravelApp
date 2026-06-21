import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_controller.dart';
import '../auth_gate.dart';
import '../localization.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'progress_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploading = false;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final response = await widget.controller.api.uploadProfilePhoto(
        File(picked.path),
      );
      widget.controller.updateUser(
        Map<String, dynamic>.from(response['data']['user'] as Map),
      );
      if (mounted) showMessage(context, context.tr('photo_updated'));
    } catch (_) {
      if (mounted) showMessage(context, context.tr('upload_failed'));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _chooseLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('app_language'),
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              _LanguageTile(
                flag: '🇬🇧',
                title: 'English',
                selected: widget.controller.locale.languageCode == 'en',
                onTap: () => Navigator.pop(sheetContext, 'en'),
              ),
              _LanguageTile(
                flag: '🇹🇿',
                title: 'Kiswahili',
                selected: widget.controller.locale.languageCode == 'sw',
                onTap: () => Navigator.pop(sheetContext, 'sw'),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) await widget.controller.setLanguage(selected);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr('account'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: _GuestProfile(
          controller: widget.controller,
          onLanguage: _chooseLanguage,
        ),
      );
    }

    final user = widget.controller.user!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('profile'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: PagePadding(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF201A2D), Color(0xFF5A2942)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      UserAvatar(user: user, radius: 52, showBorder: true),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: laravelRed,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _uploading ? null : _pickPhoto,
                          icon: _uploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.photo_camera_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user['name'].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'].toString(),
                    style: const TextStyle(color: Color(0xFFD8D1DF)),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _uploading ? null : _pickPhoto,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(context.tr('change_photo')),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFFB1AB),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Card(
              child: Column(
                children: [
                  _ProfileMenuTile(
                    icon: Icons.insights_rounded,
                    title: context.tr('my_progress'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProgressScreen(controller: widget.controller),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _ProfileMenuTile(
                    icon: Icons.language_rounded,
                    title: context.tr('language'),
                    trailing: widget.controller.locale.languageCode == 'en'
                        ? 'English'
                        : 'Kiswahili',
                    onTap: _chooseLanguage,
                  ),
                  const Divider(height: 1),
                  const _ProfileMenuTile(
                    icon: Icons.phone_android_rounded,
                    title: 'Android',
                    trailing: '7.0+',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: laravelRed,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => widget.controller.logout(),
              icon: const Icon(Icons.logout_rounded),
              label: Text(context.tr('logout')),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile({required this.controller, required this.onLanguage});

  final AppController controller;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFFE9E7),
              child: Icon(Icons.person_rounded, size: 54, color: laravelRed),
            ),
            const SizedBox(height: 18),
            Text(
              context.tr('profile_guest_title'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 9),
            Text(
              context.tr('profile_guest_message'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667085), height: 1.5),
            ),
            const SizedBox(height: 24),
            Card(
              child: _ProfileMenuTile(
                icon: Icons.language_rounded,
                title: context.tr('language'),
                trailing: controller.locale.languageCode == 'en'
                    ? 'English'
                    : 'Kiswahili',
                onTap: onLanguage,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => requireCommunityLogin(context, controller),
              icon: const Icon(Icons.login_rounded),
              label: Text(context.tr('sign_in_or_register')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE9E7),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: laravelRed),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing!, style: const TextStyle(color: Color(0xFF667085))),
          if (onTap != null) const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.title,
    required this.selected,
    required this.onTap,
  });
  final String flag;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: Icon(
        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: selected ? laravelRed : const Color(0xFF98A2B3),
      ),
    );
  }
}
