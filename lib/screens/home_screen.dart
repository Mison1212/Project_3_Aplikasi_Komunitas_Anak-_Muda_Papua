import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';
import 'applications_screen.dart';
import 'jobs_screen.dart';
import 'profile_screen.dart';
import '../widgets/app_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _api = ApiService();
  AppUser? _profile;
  int _index = 0;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final profile = await _api.getProfile(user.uid);
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      if (mounted) {
        setState(() {
          _profile = AppUser(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? 'Anggota',
            district: '-',
          );
        });
      }
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAdmin = _profile?.role == 'admin';
    if (isAdmin) {
      return const AdminScreen();
    }

    final screens = [
      DashboardTab(
        profile: _profile,
        onNavigate: (index) => setState(() => _index = index),
      ),
      const JobsScreen(),
      const ApplicationsScreen(),
      ProfileScreen(profile: _profile, onSaved: _loadProfile),
    ];
    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Beranda',
      ),
      const NavigationDestination(
        icon: Icon(Icons.work_outline),
        selectedIcon: Icon(Icons.work),
        label: 'Lowongan',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: 'Lamaran',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    if (_index >= screens.length) _index = screens.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: destinations,
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({
    super.key,
    required this.profile,
    required this.onNavigate,
  });

  final AppUser? profile;
  final ValueChanged<int> onNavigate;

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _api = ApiService();
  final _auth = AuthService();
  List<Map<String, dynamic>> _applications = [];
  List<dynamic> _jobs = [];

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final results = await Future.wait([
        _api.getMyApplications(user.uid),
        _api.getJobs(),
      ]);
      if (!mounted) return;
      setState(() {
        _applications = results[0] as List<Map<String, dynamic>>;
        _jobs = results[1];
      });
    } catch (_) {
      // Ringkasan bersifat pendukung, halaman tetap bisa ditampilkan.
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final accepted = _applications
        .where((item) => '${item['status']}'.toLowerCase() == 'accepted')
        .length;
    final statusUpdates = _applications
        .where((item) => '${item['status']}'.toLowerCase() != 'pending')
        .length;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 72),
          decoration: BoxDecoration(
            gradient: AppGradients.teal,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat datang,',
                      style: TextStyle(color: Color(0xFFC6F4EF), fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile?.name ?? 'Anggota Papua',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeroChip(
                          icon: Icons.location_on_outlined,
                          label: profile?.district ?? '-',
                        ),
                        _HeroChip(
                          icon: Icons.sell_outlined,
                          label: profile?.skill.isNotEmpty == true
                              ? profile!.skill
                              : 'Belum diisi',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        tooltip: 'Lihat notifikasi lamaran',
                        onPressed: () => widget.onNavigate(2),
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.18),
                          fixedSize: const Size(44, 44),
                        ),
                      ),
                      if (statusUpdates > 0)
                        Positioned(
                          right: -2,
                          top: -4,
                          child: _NotificationBadge(text: '$statusUpdates'),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withOpacity(0.18),
                    child: Text(
                      (profile?.name.isNotEmpty == true
                              ? profile!.name.substring(0, 1)
                              : 'A')
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -38),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Lamaran',
                    value: '${_applications.length}',
                    icon: Icons.description_outlined,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF11C5C0), Color(0xFF08AFC9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Lamaran Diterima',
                    value: '$accepted',
                    icon: Icons.check_circle_outline,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0CCB8C), Color(0xFF05B88F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        color: AppColors.titleText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _QuickAction(
                      icon: Icons.business_center_outlined,
                      title: 'Cari Lowongan',
                      subtitle: '${_jobs.length} lowongan tersedia',
                      onTap: () => widget.onNavigate(1),
                    ),
                    const SizedBox(height: 10),
                    _QuickAction(
                      icon: Icons.description_outlined,
                      title: 'Lamaran Saya',
                      subtitle: '${_applications.length} lamaran terkirim',
                      onTap: () => widget.onNavigate(2),
                    ),
                  ],
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lowongan Terbaru',
                      style: TextStyle(
                        color: AppColors.titleText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_jobs.isEmpty)
                      const Text(
                        'Belum ada lowongan terbaru.',
                        style: TextStyle(color: AppColors.mutedText),
                      )
                    else
                      for (final job in _jobs.take(2)) _LatestJobRow(job: job),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5C67),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            IconBubble(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.titleText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}

class _LatestJobRow extends StatelessWidget {
  const _LatestJobRow({required this.job});

  final dynamic job;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const IconBubble(
            icon: Icons.apartment_outlined,
            background: Color(0xFFD7FBF7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${job.title}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.titleText,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${job.company}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD7FBF7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${job.category}',
              style: const TextStyle(
                color: AppColors.darkTeal,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(
            icon: icon,
            color: const Color(0xFFD97706),
            background: const Color(0xFFFFF1D6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.titleText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
