import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String baseUrl = _resolveBaseUrl();

  static String _resolveBaseUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    final fromEnv = dotenv.env['API_BASE_URL'];
    final raw = fromDefine.isNotEmpty
        ? fromDefine
        : (fromEnv ?? 'http://127.0.0.1:8080/api');
    return raw.replaceAll('localhost', '127.0.0.1');
  }
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      final user = data['user'];
      if (user is Map && user['name'] != null) {
        await prefs.setString('user_name', user['name'].toString());
      }
      return data;
    }
    throw Exception(_formatError(response, 'Register failed'));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      final user = data['user'];
      if (user is Map && user['name'] != null) {
        await prefs.setString('user_name', user['name'].toString());
      }
      return data;
    }
    throw Exception(_formatError(response, 'Login failed'));
  }

  // Situations
  Future<List<dynamic>> getSituations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/situations'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to load situations'));
  }

  Future<List<dynamic>> getFavoriteSituations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/situations/favorites'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to load favorite situations'));
  }

  Future<void> addFavoriteSituation(int situationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/situations/$situationId/favorite'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }
    throw Exception(_formatError(response, 'Failed to add favorite'));
  }

  Future<void> removeFavoriteSituation(int situationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/situations/$situationId/favorite'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }
    throw Exception(_formatError(response, 'Failed to remove favorite'));
  }

  Future<Map<String, dynamic>> getSituation(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/situations/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to load situation'));
  }

  Future<List<dynamic>> getPublicSituations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/discover/situations'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to load public situations'));
  }

  Future<Map<String, dynamic>> getPublicSituation(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/discover/situations/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to load public situation'));
  }

  Future<void> savePublicSituation(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/discover/situations/$id/save'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 201) {
      throw Exception(_formatError(response, 'Failed to save situation'));
    }
  }

  Future<void> savePublicTopic(int topicId, int targetSituationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/discover/topics/$topicId/save'),
      headers: await _getHeaders(),
      body: jsonEncode({'target_situation_id': targetSituationId}),
    );
    if (response.statusCode != 201) {
      throw Exception(_formatError(response, 'Failed to save topic'));
    }
  }

  Future<void> savePublicQuestion(int questionId, int targetTopicId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/discover/questions/$questionId/save'),
      headers: await _getHeaders(),
      body: jsonEncode({'target_topic_id': targetTopicId}),
    );
    if (response.statusCode != 201) {
      throw Exception(_formatError(response, 'Failed to save question'));
    }
  }

  Future<Map<String, dynamic>> createSituation(String title, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/situations'),
      headers: await _getHeaders(),
      body: jsonEncode({'title': title, 'description': description}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to create situation'));
  }

  Future<void> deleteSituation(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/situations/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_formatError(response, 'Failed to delete situation'));
    }
  }

  Future<Map<String, dynamic>> updateSituation(
    int id,
    String title,
    String description,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/situations/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({'title': title, 'description': description}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to update situation'));
  }

  Future<Map<String, dynamic>> publishSituation(int id, bool isPublic) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/situations/$id/publish'),
      headers: await _getHeaders(),
      body: jsonEncode({'is_public': isPublic}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to publish situation'));
  }

  // Topics
  Future<List<dynamic>> getTopics(int situationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/situations/$situationId/topics'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to load topics'));
  }

  Future<Map<String, dynamic>> getTopic(int situationId, int topicId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/situations/$situationId/topics/$topicId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to load topic'));
  }

  Future<Map<String, dynamic>> createTopic(
    int situationId,
    String title,
    String description, {
    int? parentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/situations/$situationId/topics'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'parent_id': parentId,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to create topic'));
  }

  Future<Map<String, dynamic>> updateTopic(
    int situationId,
    int topicId,
    String title,
    String description,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/situations/$situationId/topics/$topicId'),
      headers: await _getHeaders(),
      body: jsonEncode({'title': title, 'description': description}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to update topic'));
  }

  Future<void> deleteTopic(int situationId, int topicId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/situations/$situationId/topics/$topicId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_formatError(response, 'Failed to delete topic'));
    }
  }

  // Questions
  Future<Map<String, dynamic>> createQuestion(
    int situationId,
    int topicId,
    String question,
    String answer,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/situations/$situationId/topics/$topicId/questions'),
      headers: await _getHeaders(),
      body: jsonEncode({'question': question, 'answer': answer}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to create question'));
  }

  Future<Map<String, dynamic>> updateQuestion(
    int situationId,
    int topicId,
    int questionId,
    String question,
    String answer,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/situations/$situationId/topics/$topicId/questions/$questionId'),
      headers: await _getHeaders(),
      body: jsonEncode({'question': question, 'answer': answer}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(_formatError(response, 'Failed to update question'));
  }

  Future<void> deleteQuestion(int situationId, int topicId, int questionId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/situations/$situationId/topics/$topicId/questions/$questionId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_formatError(response, 'Failed to delete question'));
    }
  }

  String _formatError(http.Response response, String fallbackMessage) {
    final body = response.body.isNotEmpty ? response.body : '<empty>';
    return '$fallbackMessage (status ${response.statusCode}): $body';
  }
}
