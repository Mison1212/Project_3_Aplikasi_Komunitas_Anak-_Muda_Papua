import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/job.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_ui.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _api = ApiService();
  final _auth = AuthService();
  final _jobSearchController = TextEditingController();
  final _userSearchController = TextEditingController();
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _applications = [];
  List<String> _districts = [];
  List<Map<String, dynamic>> _careerSpecs = [];
  List<Job> _jobs = [];
  int _index = 0;
  String _applicationFilter = 'all';
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _jobSearchController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.getAdminStats(),
        _api.getUsers(),
        _api.getApplicationReport(),
        _api.getDistricts(),
        _api.getCareerSpecs(),
        _api.getJobs(),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _users = results[1] as List<Map<String, dynamic>>;
        _applications = results[2] as List<Map<String, dynamic>>;
        _districts = results[3] as List<String>;
        _careerSpecs = results[4] as List<Map<String, dynamic>>;
        _jobs = results[5] as List<Job>;
        _loadError = null;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _loadError = _cleanError(error));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_loadError ?? 'Data admin belum dapat dimuat.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openPendingNotifications() {
    setState(() {
      _applicationFilter = 'pending';
      _index = 2;
    });
  }

  Future<void> _openCreateJob() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateJobSheet(
        districts: _districts,
        careerSpecs: _careerSpecs,
      ),
    );
    if (saved == true) _loadData();
  }

  Future<void> _openEditJob(Job job) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateJobSheet(
        job: job,
        districts: _districts,
        careerSpecs: _careerSpecs,
      ),
    );
    if (saved == true) _loadData();
  }

  Future<void> _openCreateDistrict() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateDistrictSheet(existingDistricts: _districts),
    );
    if (saved == true) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kabupaten berhasil ditambahkan.')),
        );
      }
    }
  }

  Future<void> _openEditDistrict(String district) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateDistrictSheet(
        existingDistricts: _districts,
        initialName: district,
      ),
    );
    if (saved == true) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kabupaten berhasil diperbarui.')),
        );
      }
    }
  }

  Future<void> _deleteDistrict(String district) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kabupaten'),
        content: Text('Hapus kabupaten "$district" dari data master?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteDistrict(district);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kabupaten berhasil dihapus.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_cleanError(error))),
        );
      }
    }
  }

  Future<void> _openCreateCareerSpec() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CreateCareerSpecSheet(),
    );
    if (saved == true) _loadData();
  }

  Future<void> _openEditCareerSpec(Map<String, dynamic> spec) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateCareerSpecSheet(spec: spec),
    );
    if (saved == true) _loadData();
  }

  Future<void> _deleteCareerSpec(Map<String, dynamic> spec) async {
    final id = int.tryParse('${spec['id'] ?? ''}');
    final name = '${spec['name'] ?? 'spesifikasi karir'}';
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID spesifikasi karir tidak ditemukan.')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Spesifikasi Karir'),
        content: Text('Hapus "$name" dari data master?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteCareerSpec(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spesifikasi karir berhasil dihapus.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_cleanError(error))),
        );
      }
    }
  }

  Future<void> _deleteJob(Job job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lowongan'),
        content: Text('Hapus lowongan "${job.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteJob(job.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lowongan berhasil dihapus.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lowongan belum dapat dihapus.')),
        );
      }
    }
  }

  Future<void> _updateApplication(Map<String, dynamic> item, String status) async {
    try {
      await _api.updateApplicationStatus(
        id: int.tryParse('${item['id']}') ?? 0,
        status: status,
      );
      await _loadData();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status lamaran belum dapat diubah.')),
        );
      }
    }
  }

  Future<void> _printRegistrationReport() async {
    await _openPrintReport('/applications/print_registration.php');
  }

  Future<void> _printApplicationStatusReport() async {
    await _openPrintReport('/applications/print_status.php');
  }

  Future<void> _openPrintReport(String path) async {
    if (_applications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada data untuk dicetak.')),
      );
      return;
    }

    final token = await _auth.currentUser?.getIdToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi admin tidak ditemukan. Login ulang.')),
      );
      return;
    }

    final uri = Uri.parse('${ApiService.baseUrl}$path').replace(
      queryParameters: {
        'token': token,
        't': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
    var opened = false;
    try {
      opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan cetak belum dapat dibuka.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      _buildJobs(),
      _buildApplications(),
      _buildUsers(),
      _buildMaster(),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_loadError != null
              ? _AdminLoadError(message: _loadError!, onRetry: _loadData)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: pages[_index],
                )),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined),
            selectedIcon: Icon(Icons.business_center),
            label: 'Lowongan',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Lamaran',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'User',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Master',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final stats = _stats ?? {};
    final pending = _statusCount('pending');
    final accepted = _statusCount('accepted');
    final rejected = _statusCount('rejected');
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
          decoration: const BoxDecoration(gradient: AppGradients.teal),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat datang,',
                      style: TextStyle(color: Color(0xFFC6F4EF), fontSize: 12),
                    ),
                    Text(
                      'Administrator',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$pending lamaran menunggu persetujuan',
                      style: const TextStyle(color: Color(0xFFC6F4EF)),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Lihat lamaran menunggu',
                    onPressed: _openPendingNotifications,
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.16),
                      fixedSize: const Size(48, 48),
                    ),
                  ),
                  if (pending > 0)
                    Positioned(
                      right: -2,
                      top: -4,
                      child: _Badge(text: '$pending'),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Keluar',
                onPressed: () => _auth.signOut(),
                icon: const Icon(Icons.logout, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.16),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total User',
                      value: '${stats['users'] ?? _users.length}',
                      icon: Icons.group_outlined,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      title: 'Lowongan',
                      value: '${stats['jobs'] ?? _jobs.length}',
                      icon: Icons.business_center_outlined,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Lamaran',
                      value: '${stats['applications'] ?? _applications.length}',
                      icon: Icons.assignment_outlined,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      title: 'Diterima',
                      value: '${stats['accepted'] ?? accepted}',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SummaryProgress(
                pending: pending,
                accepted: accepted,
                rejected: rejected,
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kelola Data',
                      style: TextStyle(
                        color: AppColors.titleText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _AdminMenuItem(
                      icon: Icons.business_center_outlined,
                      title: 'Kelola Lowongan',
                      subtitle: '${_jobs.length} lowongan aktif',
                      color: const Color(0xFF0284C7),
                      onTap: () => setState(() => _index = 1),
                    ),
                    _AdminMenuItem(
                      icon: Icons.group_outlined,
                      title: 'Data User',
                      subtitle: '${_users.length} pengguna terdaftar',
                      color: const Color(0xFF7C3AED),
                      onTap: () => setState(() => _index = 3),
                    ),
                    _AdminMenuItem(
                      icon: Icons.assignment_outlined,
                      title: 'Kelola Lamaran',
                      subtitle: '$pending menunggu',
                      color: AppColors.primaryTeal,
                      onTap: () => setState(() => _index = 2),
                    ),
                    _AdminMenuItem(
                      icon: Icons.map_outlined,
                      title: 'Data Master',
                      subtitle: 'Kabupaten & karir',
                      color: const Color(0xFFD97706),
                      onTap: () => setState(() => _index = 4),
                    ),
                  ],
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Lamaran Terbaru',
                            style: TextStyle(
                              color: AppColors.titleText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _index = 2),
                          child: const Text('Lihat semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final item in _applications.take(3))
                      _RecentApplicationRow(item: item),
                    if (_applications.isEmpty)
                      const Text(
                        'Belum ada lamaran terbaru.',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobs() {
    final query = _jobSearchController.text.trim().toLowerCase();
    final jobs = _jobs.where((job) {
      if (query.isEmpty) return true;
      return '${job.title} ${job.company} ${job.location} ${job.category}'
          .toLowerCase()
          .contains(query);
    }).toList();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: const BoxDecoration(gradient: AppGradients.teal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola Lowongan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        Text(
                          '${jobs.length} lowongan aktif',
                          style: const TextStyle(color: Color(0xFFC6F4EF)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tambah lowongan',
                    onPressed: _openCreateJob,
                    icon: const Icon(Icons.add, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _HeaderSearchField(
                controller: _jobSearchController,
                hint: 'Cari lowongan...',
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              for (final job in jobs)
                _AdminJobCard(
                  job: job,
                  onEdit: () => _openEditJob(job),
                  onDelete: () => _deleteJob(job),
                ),
              if (jobs.isEmpty)
                const AppCard(
                  child: Center(child: Text('Lowongan tidak ditemukan.')),
                ),
              OutlinedButton.icon(
                onPressed: _openCreateJob,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Lowongan Baru'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.primaryTeal,
                  side: const BorderSide(color: AppColors.accentTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplications() {
    final filtered = _applications.where((item) {
      if (_applicationFilter == 'all') return true;
      return '${item['status'] ?? 'pending'}'.toLowerCase() ==
          _applicationFilter;
    }).toList();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: const BoxDecoration(gradient: AppGradients.teal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelola Lamaran',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChipButton(
                      label: 'Semua (${_applications.length})',
                      selected: _applicationFilter == 'all',
                      onTap: () => setState(() => _applicationFilter = 'all'),
                    ),
                    _FilterChipButton(
                      label: 'Menunggu (${_statusCount('pending')})',
                      selected: _applicationFilter == 'pending',
                      onTap: () => setState(() => _applicationFilter = 'pending'),
                    ),
                    _FilterChipButton(
                      label: 'Diterima (${_statusCount('accepted')})',
                      selected: _applicationFilter == 'accepted',
                      onTap: () => setState(() => _applicationFilter = 'accepted'),
                    ),
                    _FilterChipButton(
                      label: 'Ditolak (${_statusCount('rejected')})',
                      selected: _applicationFilter == 'rejected',
                      onTap: () => setState(() => _applicationFilter = 'rejected'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ReportPrintButton(
                    icon: Icons.print_outlined,
                    label: 'Cetak Pendaftaran',
                    onPressed: _printRegistrationReport,
                  ),
                  _ReportPrintButton(
                    icon: Icons.assessment_outlined,
                    label: 'Cetak Status',
                    onPressed: _printApplicationStatusReport,
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              for (final item in filtered)
                _ApplicationManageCard(
                  item: item,
                  onAccept: () => _updateApplication(item, 'accepted'),
                  onReject: () => _updateApplication(item, 'rejected'),
                  onReset: () => _updateApplication(item, 'pending'),
                ),
              if (filtered.isEmpty)
                const AppCard(
                  child: Center(child: Text('Data lamaran belum ada.')),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsers() {
    final query = _userSearchController.text.trim().toLowerCase();
    final users = _users.where((user) {
      if (query.isEmpty) return true;
      return '${user['name']} ${user['district']} ${user['skill']} ${user['email']}'
          .toLowerCase()
          .contains(query);
    }).toList();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: const BoxDecoration(gradient: AppGradients.teal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data User',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 14),
              _HeaderSearchField(
                controller: _userSearchController,
                hint: 'Cari nama, kabupaten, karir...',
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${users.length} pengguna ditemukan',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              for (final user in users) _UserCard(user: user),
              if (users.isEmpty)
                const AppCard(
                  child: Center(child: Text('User tidak ditemukan.')),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaster() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          decoration: const BoxDecoration(gradient: AppGradients.teal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Master',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kabupaten & Spesifikasi Karir',
                style: TextStyle(color: Color(0xFFC6F4EF)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryTeal,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Asal Kabupaten',
                            style: TextStyle(
                              color: AppColors.titleText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '${_districts.length} data',
                          style: const TextStyle(color: AppColors.mutedText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _MasterAddButton(
                      label: 'Tambah Kabupaten Baru',
                      icon: Icons.add_location_alt_outlined,
                      onPressed: _openCreateDistrict,
                    ),
                    const SizedBox(height: 14),
                    Column(
                      children: [
                        for (final district in _districts) ...[
                          _MasterChip(
                            label: district,
                            onEdit: () => _openEditDistrict(district),
                            onDelete: () => _deleteDistrict(district),
                          ),
                          if (district != _districts.last)
                            const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Spesifikasi Karir',
                            style: TextStyle(
                              color: AppColors.titleText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_careerSpecs.length} bidang karir terdaftar',
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 14),
                    _MasterAddButton(
                      label: 'Tambah Spesifikasi Karir',
                      icon: Icons.add_circle_outline,
                      onPressed: _openCreateCareerSpec,
                    ),
                    const SizedBox(height: 14),
                    Column(
                      children: [
                        for (final spec in _careerSpecs) ...[
                          _MasterChip(
                            label: '${spec['name'] ?? '-'}',
                            onEdit: () => _openEditCareerSpec(spec),
                            onDelete: () => _deleteCareerSpec(spec),
                          ),
                          if (spec != _careerSpecs.last)
                            const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _statusCount(String status) {
    return _applications
        .where((item) => '${item['status'] ?? 'pending'}'.toLowerCase() == status)
        .length;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconBubble(
            icon: icon,
            color: color,
            background: color.withOpacity(0.12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.titleText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminLoadError extends StatelessWidget {
  const _AdminLoadError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: Color(0xFFD97706),
                size: 46,
              ),
              const SizedBox(height: 14),
              const Text(
                'Data admin belum dapat dimuat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.titleText,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.mutedText),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryProgress extends StatelessWidget {
  const _SummaryProgress({
    required this.pending,
    required this.accepted,
    required this.rejected,
  });

  final int pending;
  final int accepted;
  final int rejected;

  @override
  Widget build(BuildContext context) {
    final total = pending + accepted + rejected;
    final safeTotal = total == 0 ? 1 : total;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Lamaran',
            style: TextStyle(
              color: AppColors.titleText,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Row(
              children: [
                _ProgressPart(
                  color: const Color(0xFFFBBF24),
                  flex: pending == 0 ? 1 : pending,
                  visible: total == 0 || pending > 0,
                  total: safeTotal,
                ),
                _ProgressPart(
                  color: const Color(0xFF10B981),
                  flex: accepted == 0 ? 1 : accepted,
                  visible: accepted > 0,
                  total: safeTotal,
                ),
                _ProgressPart(
                  color: const Color(0xFFFF5C67),
                  flex: rejected == 0 ? 1 : rejected,
                  visible: rejected > 0,
                  total: safeTotal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _Legend(color: const Color(0xFFFBBF24), label: 'Menunggu $pending'),
              _Legend(color: const Color(0xFF10B981), label: 'Diterima $accepted'),
              _Legend(color: const Color(0xFFFF5C67), label: 'Ditolak $rejected'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressPart extends StatelessWidget {
  const _ProgressPart({
    required this.color,
    required this.flex,
    required this.visible,
    required this.total,
  });

  final Color color;
  final int flex;
  final bool visible;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: Container(height: 12, color: color),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AdminMenuItem extends StatelessWidget {
  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            IconBubble(
              icon: icon,
              color: color,
              background: color.withOpacity(0.12),
            ),
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

class _RecentApplicationRow extends StatelessWidget {
  const _RecentApplicationRow({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final name = '${item['name'] ?? '-'}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accentTeal,
            child: Text(
              _initial(name),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.titleText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${item['title'] ?? '-'}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
          StatusPill(status: '${item['status'] ?? 'pending'}'),
        ],
      ),
    );
  }
}

class _HeaderSearchField extends StatelessWidget {
  const _HeaderSearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        fillColor: Colors.white.withOpacity(0.18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.26)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

class _AdminJobCard extends StatelessWidget {
  const _AdminJobCard({
    required this.job,
    required this.onEdit,
    required this.onDelete,
  });

  final Job job;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconBubble(icon: Icons.apartment_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        color: AppColors.titleText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      job.company,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MiniChip(label: job.category),
                        _MiniChip(label: job.location, icon: Icons.location_on_outlined),
                        _MiniChip(label: job.deadline, icon: Icons.schedule),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.salary.isNotEmpty ? job.salary : _salaryText(job.category),
                      style: const TextStyle(
                        color: AppColors.darkTeal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFEFF6FF),
                    side: const BorderSide(color: Color(0xFFD7E7FF)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Hapus'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    backgroundColor: const Color(0xFFFFF1F1),
                    side: const BorderSide(color: Color(0xFFFFD6D6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicationManageCard extends StatelessWidget {
  const _ApplicationManageCard({
    required this.item,
    required this.onAccept,
    required this.onReject,
    required this.onReset,
  });

  final Map<String, dynamic> item;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final status = '${item['status'] ?? 'pending'}'.toLowerCase();
    final name = '${item['name'] ?? '-'}';
    final phone = '${item['phone'] ?? ''}'.trim();
    return AppCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accentTeal,
                child: Text(
                  _initial(name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.titleText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${item['title'] ?? '-'}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                    Text(
                      '${item['company'] ?? '-'}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        phone,
                        style: const TextStyle(
                          color: AppColors.darkTeal,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              StatusPill(status: status),
            ],
          ),
          const Divider(height: 26),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${item['created_at'] ?? '-'}',
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              if (phone.isNotEmpty)
                _StatusAction(
                  label: 'WhatsApp',
                  color: AppColors.primaryTeal,
                  onTap: () => _openWhatsApp(
                    context,
                    phone: phone,
                    name: name,
                    jobTitle: '${item['title'] ?? '-'}',
                    status: status,
                  ),
                ),
              if (status != 'accepted')
                _StatusAction(
                  label: 'Terima',
                  color: const Color(0xFF059669),
                  onTap: onAccept,
                ),
              if (status != 'rejected')
                _StatusAction(
                  label: 'Tolak',
                  color: const Color(0xFFE53935),
                  onTap: onReject,
                ),
              if (status != 'pending')
                _StatusAction(
                  label: 'Reset',
                  color: const Color(0xFFD97706),
                  onTap: onReset,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusAction extends StatelessWidget {
  const _StatusAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: BorderSide(color: color.withOpacity(0.36)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    final name = '${user['name'] ?? '-'}';
    final phone = '${user['phone'] ?? ''}'.trim();
    final email = '${user['email'] ?? '-'}';
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accentTeal,
            child: Text(
              _initial(name),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.titleText,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Text(
                      '1\nlamaran',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniChip(label: '${user['district'] ?? '-'}', icon: Icons.location_on_outlined),
                    _MiniChip(label: '${user['skill'] ?? '-'}', icon: Icons.sell_outlined),
                  ],
                ),
                const Divider(height: 22),
                Text(
                  email,
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
                Text(
                  phone.isEmpty ? 'Nomor telepon belum diisi' : phone,
                  style: TextStyle(
                    color: phone.isEmpty ? AppColors.mutedText : AppColors.darkTeal,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _openWhatsApp(
                      context,
                      phone: phone,
                      name: name,
                    ),
                    icon: const Icon(Icons.chat_outlined, size: 16),
                    label: const Text('Hubungi WhatsApp'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryTeal,
                      side: const BorderSide(color: Color(0xFFCBEDE9)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: onTap,
        label: Text(label),
        labelStyle: TextStyle(
          color: AppColors.darkTeal,
          fontWeight: FontWeight.w900,
        ),
        backgroundColor:
            selected ? AppColors.cardSurface : const Color(0xFFFFF3C4),
        side: BorderSide(
          color: selected ? AppColors.cardSurface : const Color(0xFFE8D996),
          width: 1.2,
        ),
        elevation: selected ? 2 : 0,
        shadowColor: AppColors.darkTeal.withOpacity(0.18),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}

class _ReportPrintButton extends StatelessWidget {
  const _ReportPrintButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkTeal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F5F3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFCBEDE9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: AppColors.primaryTeal),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: const TextStyle(
              color: AppColors.darkTeal,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterAddButton extends StatelessWidget {
  const _MasterAddButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          foregroundColor: AppColors.darkTeal,
          backgroundColor: AppColors.inputFill,
          side: const BorderSide(color: Color(0xFFBDE8E3), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _MasterChip extends StatelessWidget {
  const _MasterChip({
    required this.label,
    this.onEdit,
    this.onDelete,
  });

  final String label;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBDE8E3), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkTeal.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onEdit,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.darkTeal,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            _MasterIconAction(
              tooltip: 'Edit $label',
              icon: Icons.edit_outlined,
              color: AppColors.primaryTeal,
              onPressed: onEdit,
            ),
            _MasterIconAction(
              tooltip: 'Hapus $label',
              icon: Icons.delete_outline,
              color: const Color(0xFFE11D48),
              onPressed: onDelete,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _MasterIconAction extends StatelessWidget {
  const _MasterIconAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: Color(0xFFFF5C67),
        shape: BoxShape.circle,
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

class _CreateJobSheet extends StatefulWidget {
  const _CreateJobSheet({
    this.job,
    this.districts = const [],
    this.careerSpecs = const [],
  });

  final Job? job;
  final List<String> districts;
  final List<Map<String, dynamic>> careerSpecs;

  @override
  State<_CreateJobSheet> createState() => _CreateJobSheetState();
}

class _CreateJobSheetState extends State<_CreateJobSheet> {
  final _api = ApiService();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _salaryController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _deadlineController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    if (job != null) {
      _titleController.text = job.title;
      _companyController.text = job.company;
      _salaryController.text = job.salary;
      _locationController.text = job.location;
      _categoryController.text = job.category;
      _descriptionController.text = job.description;
      _requirementsController.text = job.requirements;
      _deadlineController.text = job.deadline;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final company = _companyController.text.trim();
    final salary = _salaryController.text.trim();
    final location = _locationController.text.trim();
    final category = _categoryController.text.trim();
    final description = _descriptionController.text.trim();
    final requirements = _requirementsController.text.trim();
    final deadline = _deadlineController.text.trim();
    final normalizedDeadline = _normalizeDeadline(deadline);
    if ([title, company, salary, location, category, description, requirements, deadline]
        .any((value) => value.isEmpty)) {
      _showMessage('Semua data lowongan wajib diisi.');
      return;
    }
    if (normalizedDeadline == null) {
      _showMessage('Deadline harus memakai format DD/MM/YYYY atau YYYY-MM-DD.');
      return;
    }
    setState(() => _saving = true);
    try {
      final job = widget.job;
      if (job == null) {
        await _api.createJob(
          title: title,
          company: company,
          location: location,
          category: category,
          salary: salary,
          description: description,
          requirements: requirements,
          deadline: normalizedDeadline,
        );
      } else {
        await _api.updateJob(
          id: job.id,
          title: title,
          company: company,
          location: location,
          category: category,
          salary: salary,
          description: description,
          requirements: requirements,
          deadline: normalizedDeadline,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_cleanError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetScaffold(
      title: widget.job == null ? 'Tambah Lowongan' : 'Edit Lowongan',
      children: [
        _Field(controller: _titleController, label: 'Judul lowongan'),
        _Field(controller: _companyController, label: 'Nama perusahaan'),
        _Field(controller: _salaryController, label: 'Gaji'),
        _DropdownField(
          controller: _locationController,
          label: 'Lokasi',
          items: widget.districts,
        ),
        _DropdownField(
          controller: _categoryController,
          label: 'Kategori',
          items: widget.careerSpecs.map((spec) => '${spec['name']}').toList(),
        ),
        _DeadlineField(controller: _deadlineController),
        _Field(controller: _descriptionController, label: 'Deskripsi', maxLines: 4),
        _Field(controller: _requirementsController, label: 'Persyaratan', maxLines: 4),
        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Menyimpan...' : 'Simpan Lowongan'),
        ),
      ],
    );
  }
}

class _CreateDistrictSheet extends StatefulWidget {
  const _CreateDistrictSheet({
    this.existingDistricts = const [],
    this.initialName,
  });

  final List<String> existingDistricts;
  final String? initialName;

  @override
  State<_CreateDistrictSheet> createState() => _CreateDistrictSheetState();
}

class _CreateDistrictSheetState extends State<_CreateDistrictSheet> {
  final _api = ApiService();
  final _nameController = TextEditingController();
  bool _saving = false;
  bool get _isEditing => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Nama kabupaten wajib diisi.');
      return;
    }
    final alreadyExists = widget.existingDistricts.any(
      (district) =>
          district.trim().toLowerCase() == name.toLowerCase() &&
          district.trim().toLowerCase() !=
              (widget.initialName ?? '').trim().toLowerCase(),
    );
    if (alreadyExists) {
      _showMessage('Kabupaten "$name" sudah ada di data master.');
      return;
    }
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await _api.updateDistrict(oldName: widget.initialName!, name: name);
      } else {
        await _api.createDistrict(name);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_cleanError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetScaffold(
      title: _isEditing ? 'Edit Kabupaten' : 'Tambah Kabupaten',
      children: [
        _Field(controller: _nameController, label: 'Nama kabupaten'),
        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Menyimpan...' : 'Simpan Kabupaten'),
        ),
      ],
    );
  }
}

class _CreateCareerSpecSheet extends StatefulWidget {
  const _CreateCareerSpecSheet({this.spec});

  final Map<String, dynamic>? spec;

  @override
  State<_CreateCareerSpecSheet> createState() => _CreateCareerSpecSheetState();
}

class _CreateCareerSpecSheetState extends State<_CreateCareerSpecSheet> {
  final _api = ApiService();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;
  bool get _isEditing => widget.spec != null;

  @override
  void initState() {
    super.initState();
    final spec = widget.spec;
    if (spec != null) {
      _nameController.text = '${spec['name'] ?? ''}';
      _descriptionController.text = '${spec['description'] ?? ''}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama spesifikasi karir wajib diisi.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final id = int.tryParse('${widget.spec!['id'] ?? ''}');
        if (id == null) {
          _showMessage('ID spesifikasi karir tidak ditemukan.');
          return;
        }
        await _api.updateCareerSpec(
          id: id,
          name: name,
          description: description,
        );
      } else {
        await _api.createCareerSpec(name: name, description: description);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_cleanError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetScaffold(
      title: _isEditing ? 'Edit Spesifikasi Karir' : 'Tambah Spesifikasi Karir',
      children: [
        _Field(controller: _nameController, label: 'Nama spesifikasi karir'),
        _Field(controller: _descriptionController, label: 'Deskripsi', maxLines: 3),
        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Menyimpan...' : 'Simpan Karir'),
        ),
      ],
    );
  }
}

class _BottomSheetScaffold extends StatelessWidget {
  const _BottomSheetScaffold({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.titleText,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _DropdownField extends StatefulWidget {
  const _DropdownField({
    required this.controller,
    required this.label,
    required this.items,
  });

  final TextEditingController controller;
  final String label;
  final List<String> items;

  @override
  State<_DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<_DropdownField> {
  @override
  Widget build(BuildContext context) {
    final values = widget.items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    if (values.isEmpty) {
      return _Field(controller: widget.controller, label: widget.label);
    }
    final current = values.contains(widget.controller.text.trim())
        ? widget.controller.text.trim()
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: current,
        decoration: InputDecoration(labelText: widget.label),
        items: values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(value),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() => widget.controller.text = value);
        },
      ),
    );
  }
}

class _DeadlineField extends StatelessWidget {
  const _DeadlineField({required this.controller});

  final TextEditingController controller;

  Future<void> _pickDate(BuildContext context) async {
    final initial = _parseDeadline(controller.text) ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (selected == null) return;
    controller.text =
        '${selected.day.toString().padLeft(2, '0')}/${selected.month.toString().padLeft(2, '0')}/${selected.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickDate(context),
        decoration: const InputDecoration(
          labelText: 'Deadline',
          hintText: 'dd/mm/yyyy',
          suffixIcon: Icon(Icons.calendar_today_outlined),
        ),
      ),
    );
  }
}

String _initial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || trimmed == '-') return 'A';
  return trimmed.substring(0, 1).toUpperCase();
}

DateTime? _parseDeadline(String value) {
  final trimmed = value.trim();
  final isoMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(trimmed);
  if (isoMatch != null) {
    return DateTime.tryParse(trimmed);
  }

  final localMatch = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(trimmed);
  if (localMatch == null) return null;
  final day = int.tryParse(localMatch.group(1)!);
  final month = int.tryParse(localMatch.group(2)!);
  final year = int.tryParse(localMatch.group(3)!);
  if (day == null || month == null || year == null) return null;
  return DateTime.tryParse(
    '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
  );
}

String? _normalizeDeadline(String value) {
  final date = _parseDeadline(value);
  if (date == null) return null;
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _cleanError(Object error) {
  final message = error.toString().replaceFirst('Exception: ', '').trim();
  if (message.isEmpty) return 'Lowongan belum dapat disimpan.';
  return message;
}

String _whatsAppPhone(String value) {
  var phone = value.replaceAll(RegExp(r'[^0-9+]'), '').trim();
  if (phone.startsWith('+')) {
    phone = phone.substring(1);
  }
  if (phone.startsWith('0')) {
    phone = '62${phone.substring(1)}';
  }
  return phone;
}

Future<void> _openWhatsApp(
  BuildContext context, {
  required String phone,
  required String name,
  String? jobTitle,
  String? status,
}) async {
  final normalizedPhone = _whatsAppPhone(phone);
  if (normalizedPhone.length < 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nomor WhatsApp belum valid.')),
    );
    return;
  }

  final statusText = switch (status) {
    'accepted' => 'diterima',
    'rejected' => 'ditolak',
    _ => 'sedang diproses',
  };
  final message = jobTitle == null
      ? 'Halo $name, kami dari Karir Muda Papua ingin menghubungi kamu.'
      : 'Halo $name, kami dari Karir Muda Papua. Lamaran kamu untuk lowongan $jobTitle $statusText.';
  final encodedMessage = Uri.encodeComponent(message);
  final appUri = Uri.parse(
    'whatsapp://send?phone=$normalizedPhone&text=$encodedMessage',
  );
  final webUri = Uri.parse(
    'https://wa.me/$normalizedPhone?text=${Uri.encodeComponent(message)}',
  );

  final opened = await launchUrl(appUri, mode: LaunchMode.externalApplication) ||
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WhatsApp belum dapat dibuka.')),
    );
  }
}

String _salaryText(String category) {
  final value = category.toLowerCase();
  if (value.contains('software') || value.contains('teknologi')) {
    return 'Rp 5.000.000 - Rp 8.000.000';
  }
  if (value.contains('kesehatan')) {
    return 'Rp 4.000.000 - Rp 6.000.000';
  }
  if (value.contains('pendidikan')) {
    return 'Rp 3.500.000 - Rp 5.500.000';
  }
  if (value.contains('administrasi')) {
    return 'Rp 4.500.000 - Rp 7.000.000';
  }
  return 'Gaji menyesuaikan kebijakan instansi';
}
