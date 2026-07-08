import 'package:flutter/material.dart';

import '../models/job.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_ui.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _api = ApiService();
  final _auth = AuthService();
  final _searchController = TextEditingController();
  final List<Job> _jobs = [];
  Set<int> _appliedJobIds = {};
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadAppliedJobs();
    _loadJobs(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final nextPage = reset ? 1 : _page;
      final items = await _api.getJobs(
        query: _searchController.text.trim(),
        page: nextPage,
      );
      setState(() {
        if (reset) _jobs.clear();
        _jobs.addAll(items);
        _page = nextPage + 1;
        _hasMore = items.length >= 10;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data lowongan belum dapat dimuat.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadAppliedJobs() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final applications = await _api.getMyApplications(user.uid);
      final jobIds = applications
          .map((item) => int.tryParse('${item['job_id'] ?? ''}') ?? 0)
          .where((id) => id > 0)
          .toSet();
      if (mounted) setState(() => _appliedJobIds = jobIds);
    } catch (_) {
      // Status terdaftar hanya penanda tambahan. Daftar lowongan tetap ditampilkan.
    }
  }

  Future<void> _refreshJobs() async {
    await Future.wait([
      _loadAppliedJobs(),
      _loadJobs(reset: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshJobs,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: const BoxDecoration(gradient: AppGradients.teal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cari Lowongan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _loadJobs(reset: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari pekerjaan, perusahaan...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: IconButton(
                      tooltip: 'Cari',
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () => _loadJobs(reset: true),
                    ),
                    fillColor: Colors.white.withOpacity(0.18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.26),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              '${_jobs.length} lowongan ditemukan',
              style: const TextStyle(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (final job in _jobs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _JobCard(
                job: job,
                isApplied: _appliedJobIds.contains(job.id),
                onReturn: _refreshJobs,
              ),
            ),
          if (_jobs.isEmpty && !_loading)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: Text('Belum ada lowongan ditampilkan.')),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_hasMore && !_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () => _loadJobs(),
                icon: const Icon(Icons.expand_more),
                label: const Text('Muat lagi'),
              ),
            ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.isApplied,
    required this.onReturn,
  });

  final Job job;
  final bool isApplied;
  final Future<void> Function() onReturn;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id)),
          ).then((_) => onReturn());
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBubble(icon: Icons.business_center_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.titleText,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                      _MiniChip(
                        label: job.location,
                        icon: Icons.location_on_outlined,
                        muted: true,
                      ),
                      _MiniChip(
                        label: job.deadline,
                        icon: Icons.schedule,
                        muted: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isApplied)
              const _AppliedBadge()
            else
              const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}

class _AppliedBadge extends StatelessWidget {
  const _AppliedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD9FBE8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Text(
        'Terdaftar',
        style: TextStyle(
          color: Color(0xFF047857),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, this.icon, this.muted = false});

  final String label;
  final IconData? icon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: muted ? Colors.transparent : const Color(0xFFE0F5F3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: muted ? AppColors.cardBorder : const Color(0xFFCBEDE9),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: AppColors.mutedText),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: muted ? AppColors.mutedText : AppColors.darkTeal,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
