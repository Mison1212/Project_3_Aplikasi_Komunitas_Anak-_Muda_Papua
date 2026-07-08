import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/app_user.dart';
import '../models/job.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static String get baseUrl => AppConfig.apiBaseUrl;
  static const _requestTimeout = Duration(seconds: 12);

  final http.Client _client;

  Future<AppUser> syncProfile(AppUser user) async {
    final response = await _post('/users/sync.php', user.toJson());
    return AppUser.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<AppUser> getProfile(String uid) async {
    final response = await _get('/users/detail.php?uid=$uid');
    return AppUser.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<String>> getDistricts() async {
    final response = await _get('/districts/list.php');
    return ((response['data'] ?? []) as List).map((item) => '$item').toList();
  }

  Future<void> createDistrict(String name) async {
    await _post('/districts/create.php', {'name': name});
  }

  Future<void> updateDistrict({
    required String oldName,
    required String name,
  }) async {
    await _post('/districts/update.php', {
      'old_name': oldName,
      'name': name,
    });
  }

  Future<void> deleteDistrict(String name) async {
    await _post('/districts/delete.php', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getCareerSpecs() async {
    final response = await _get('/career_specs/list.php');
    return ((response['data'] ?? []) as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  Future<void> createCareerSpec({
    required String name,
    String description = '',
  }) async {
    await _post('/career_specs/create.php', {
      'name': name,
      'description': description,
    });
  }

  Future<void> updateCareerSpec({
    required int id,
    required String name,
    String description = '',
  }) async {
    await _post('/career_specs/update.php', {
      'id': id,
      'name': name,
      'description': description,
    });
  }

  Future<void> deleteCareerSpec(int id) async {
    await _post('/career_specs/delete.php', {'id': id});
  }

  Future<List<Job>> getJobs({String query = '', int page = 1}) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final response = await _get('/jobs/list.php?q=$encodedQuery&page=$page');
    return ((response['data'] ?? []) as List)
        .map((item) => Job.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Job> getJobDetail(int id) async {
    final response = await _get('/jobs/detail.php?id=$id');
    return Job.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> applyJob({required String uid, required int jobId}) async {
    await _post('/applications/create.php', {
      'firebase_uid': uid,
      'job_id': jobId,
    });
  }

  Future<List<Map<String, dynamic>>> getMyApplications(String uid) async {
    final response = await _get('/applications/list.php?uid=$uid');
    return ((response['data'] ?? []) as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final response = await _get('/admin/stats.php');
    return response['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getUsers({String query = ''}) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final response = await _get('/users/list.php?q=$encodedQuery');
    return ((response['data'] ?? []) as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getApplicationReport() async {
    final response = await _get('/applications/report.php');
    return ((response['data'] ?? []) as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  Future<void> createJob({
    required String title,
    required String company,
    required String location,
    required String category,
    required String salary,
    required String description,
    required String requirements,
    required String deadline,
  }) async {
    await _post('/jobs/create.php', {
      'title': title,
      'company': company,
      'location': location,
      'category': category,
      'salary': salary,
      'description': description,
      'requirements': requirements,
      'deadline': deadline,
    });
  }

  Future<void> updateJob({
    required int id,
    required String title,
    required String company,
    required String location,
    required String category,
    required String salary,
    required String description,
    required String requirements,
    required String deadline,
  }) async {
    await _post('/jobs/update.php', {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'category': category,
      'salary': salary,
      'description': description,
      'requirements': requirements,
      'deadline': deadline,
    });
  }

  Future<void> deleteJob(int id) async {
    await _post('/jobs/delete.php', {'id': id});
  }

  Future<void> updateApplicationStatus({
    required int id,
    required String status,
  }) async {
    await _post('/applications/update_status.php', {
      'id': id,
      'status': status,
    });
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client
        .get(uri, headers: await _headers())
        .timeout(_requestTimeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client
        .post(
          uri,
          headers: await _headers(json: true),
          body: jsonEncode(body),
        )
        .timeout(_requestTimeout);
    return _decode(response);
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';

    final token = await FirebaseAuth.instance.currentUser
        ?.getIdToken()
        .timeout(_requestTimeout);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Permintaan gagal diproses.');
    }
    return data;
  }
}
