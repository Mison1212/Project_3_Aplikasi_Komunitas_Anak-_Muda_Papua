import 'package:flutter/material.dart';

import '../models/job.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_ui.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final int jobId;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _api = ApiService();
  final _auth = AuthService();
  Job? _job;
  bool _loading = true;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final job = await _api.getJobDetail(widget.jobId);
      if (mounted) setState(() => _job = job);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detail lowongan belum dapat dimuat.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply() async {
    final user = _auth.currentUser;
    if (user == null) return;
    setState(() => _applying = true);
    try {
      await _api.applyJob(uid: user.uid, jobId: widget.jobId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran lowongan berhasil dikirim.')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran gagal atau sudah pernah dikirim.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : job == null
              ? const Center(child: Text('Data tidak ditemukan.'))
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 34),
                      decoration: const BoxDecoration(
                        gradient: AppGradients.teal,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            tooltip: 'Kembali',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.16),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.apartment_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    Text(
                                      job.company,
                                      style: const TextStyle(
                                        color: Color(0xFFC6F4EF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _HeaderChip(
                                icon: Icons.location_on_outlined,
                                label: job.location,
                              ),
                              _HeaderChip(
                                icon: Icons.sell_outlined,
                                label: job.category,
                              ),
                              _HeaderChip(
                                icon: Icons.schedule,
                                label: 'Deadline: ${job.deadline}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -18),
                            child: AppCard(
                              margin: EdgeInsets.zero,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Gaji',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.titleText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    job.salary.isNotEmpty
                                        ? job.salary
                                        : _salaryText(job.category),
                                    style: const TextStyle(
                                      color: AppColors.darkTeal,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _Section(title: 'Deskripsi', body: job.description),
                          _Section(
                            title: 'Persyaratan',
                            body: job.requirements,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _applying ? null : _apply,
                            icon: const Icon(Icons.send),
                            label: Text(
                              _applying ? 'Mengirim...' : 'Daftar Lowongan',
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

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
  if (value.contains('administrasi')) {
    return 'Rp 4.500.000 - Rp 7.000.000';
  }
  return 'Disesuaikan dengan kebijakan instansi';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
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
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: AppColors.mutedText)),
        ],
      ),
    );
  }
}
