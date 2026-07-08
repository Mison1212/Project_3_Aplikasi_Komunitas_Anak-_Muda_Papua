import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onSaved,
  });

  final AppUser? profile;
  final VoidCallback onSaved;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _api = ApiService();
  final _auth = AuthService();
  List<String> _districts = [];
  List<Map<String, dynamic>> _careerSpecs = [];
  String? _selectedDistrict;
  String? _selectedSkill;
  bool _saving = false;
  bool _loadingMasterData = true;

  @override
  void initState() {
    super.initState();
    _fill();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) _fill();
  }

  void _fill() {
    final profile = widget.profile;
    _nameController.text = profile?.name ?? '';
    _phoneController.text = profile?.phone ?? '';
    _selectedDistrict = profile?.district.isNotEmpty == true
        ? profile!.district
        : _selectedDistrict;
    _selectedSkill =
        profile?.skill.isNotEmpty == true ? profile!.skill : _selectedSkill;
    _loadMasterData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    try {
      final districts = await _api.getDistricts();
      final careerSpecs = await _api.getCareerSpecs();
      if (!mounted) return;
      setState(() {
        _districts = [...districts];
        if (_selectedDistrict != null &&
            !_districts.contains(_selectedDistrict)) {
          _districts.add(_selectedDistrict!);
        }
        _careerSpecs = [...careerSpecs];
        final specNames =
            _careerSpecs.map((spec) => '${spec['name']}').toList();
        if (_selectedSkill != null && !specNames.contains(_selectedSkill)) {
          _careerSpecs.add(
              {'name': _selectedSkill, 'description': 'Data profil saat ini'});
        }
        if (_selectedDistrict == null && districts.isNotEmpty) {
          _selectedDistrict = districts.first;
        }
        if (_selectedSkill == null && careerSpecs.isNotEmpty) {
          _selectedSkill = '${careerSpecs.first['name']}';
        }
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Data kabupaten dan karir belum dapat dimuat.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMasterData = false);
    }
  }

  Future<void> _save() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap wajib diisi.')),
      );
      return;
    }
    if (_selectedDistrict == null || _selectedSkill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Pilih kabupaten dan spesifikasi karir terlebih dahulu.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _api.syncProfile(
        AppUser(
          uid: user.uid,
          email: user.email ?? '',
          name: name,
          district: _selectedDistrict!,
          phone: phone,
          skill: _selectedSkill!,
        ),
      );
      widget.onSaved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil belum dapat disimpan.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const GradientHeader(
          title: 'Profil Saya',
          subtitle: 'Kelola data pribadi kamu',
          padding: EdgeInsets.fromLTRB(24, 28, 24, 48),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Transform.translate(
            offset: const Offset(0, -28),
            child: Column(
              children: [
                AppCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.accentTeal,
                        child: Text(
                          (_nameController.text.trim().isNotEmpty
                                  ? _nameController.text.trim().substring(0, 1)
                                  : 'A')
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.trim().isNotEmpty
                                  ? _nameController.text.trim()
                                  : 'Anggota Papua',
                              style: const TextStyle(
                                color: AppColors.titleText,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${_selectedDistrict ?? '-'} | ${_selectedSkill ?? '-'}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: AppColors.primaryTeal,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Edit Profil',
                            style: TextStyle(
                              color: AppColors.titleText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Nama lengkap',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Nomor telepon',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          'profile-district-$_selectedDistrict-${_districts.length}',
                        ),
                        initialValue:
                            _dropdownValue(_selectedDistrict, _districts),
                        items: _districts
                            .map(
                              (district) => DropdownMenuItem(
                                value: district,
                                child: Text(district),
                              ),
                            )
                            .toList(),
                        onChanged: _loadingMasterData
                            ? null
                            : (value) => setState(
                                  () => _selectedDistrict = value,
                                ),
                        decoration: const InputDecoration(
                          labelText: 'Asal kabupaten',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          'profile-skill-$_selectedSkill-${_careerSpecs.length}',
                        ),
                        initialValue: _dropdownValue(
                          _selectedSkill,
                          _careerSpecs
                              .map((spec) => '${spec['name']}')
                              .toList(),
                        ),
                        items: _careerSpecs
                            .map(
                              (spec) => DropdownMenuItem(
                                value: '${spec['name']}',
                                child: Text('${spec['name']}'),
                              ),
                            )
                            .toList(),
                        onChanged: _loadingMasterData
                            ? null
                            : (value) => setState(() => _selectedSkill = value),
                        decoration: const InputDecoration(
                          labelText: 'Spesifikasi karir',
                          prefixIcon: Icon(Icons.work_history_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _saving || _loadingMasterData ? null : _save,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(
                          _loadingMasterData
                              ? 'Memuat data...'
                              : _saving
                                  ? 'Menyimpan...'
                                  : 'Simpan Profil',
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _auth.signOut(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: Colors.red,
                    backgroundColor: const Color(0xFFFFF1F1),
                    side: const BorderSide(color: Color(0xFFFFD6D6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Keluar'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? _dropdownValue(String? value, List<String> items) {
    if (value == null || !items.contains(value)) return null;
    return value;
  }
}

