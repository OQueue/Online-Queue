import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import './domain.dart';

class AuthApi {
  final String apiUrl;
  final String authUrl;

  AuthApi(this.apiUrl, this.authUrl);

  static AuthApi fromUrl(String url) {
    final baseUrl = '$url/api';
    final baseAuthUrl = '$url/auth';
    return AuthApi(baseUrl, baseAuthUrl);
  }

  Future<UserInfo> meByToken(String token) async {
    final url = '$apiUrl/users/me';
    final headers = {'Authorization': 'Bearer $token'};
    final response = throwResponse(await http.get(Uri.parse(url), headers: headers));
    final codeUnits = response.body.codeUnits;
    final body = Utf8Decoder().convert(codeUnits);
    final dynamic u = jsonDecode(body);
    return UserInfo(
      id: u['id'],
      name: u['name'],
    );
  }

  Future<Api> signin(String login, String password) async {
    final url = '$authUrl/signin';
    final body = jsonEncode({'login': login, 'password': password});
    final headers = { 'Content-Type': 'application/json' };
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    if(response.statusCode == 200) {
      final dynamic responseJson = jsonDecode(response.body);
      final String token = responseJson['token'];
      final UserInfo me = await this.meByToken(token);
      return Api(token, apiUrl, me);
    } else {
      throw Exception(response.body);
    }
  }

  Future<Api> signup(String email, String name, String password) async {
    final url = '$authUrl/signup';
    final body = jsonEncode({'email': email, 'name': name, 'password': password});
    final headers = { 'Content-Type': 'application/json' };
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    if(response.statusCode == 200) {
      return this.signin(email, password);
    } else {
      throw Exception(response.body);
    }
  }
}

http.Response throwResponse(http.Response res) {
  if(res.statusCode == 200) {
    return res;
  } else {
    throw Exception(res.body);
  }
}

class Api {
  final String token;
  final String apiUrl;
  final UserInfo me;

  Api(this.token, this.apiUrl, this.me);

  static Api fromServerUrlWithToken(String url, String token, UserInfo me) {
    final baseUrl = '$url/api';
    return Api(token, baseUrl, me);
  }

  Future<UserInfo> getMe() async {
    final url = '$apiUrl/users/me';
    final headers = {'Authorization': 'Bearer $token'};
    final response = throwResponse(await http.get(Uri.parse(url), headers: headers));
    final codeUnits = response.body.codeUnits;
    final body = Utf8Decoder().convert(codeUnits);
    final dynamic u = jsonDecode(body);
    return UserInfo(
      id: u['id'],
      name: u['name'],
    );
  }

  Future<List<MemberInfo>> getMembers(String queueId) async {
    final url = '$apiUrl/queues/$queueId/members';
    final headers = {'Authorization': 'Bearer $token'};
    final response = throwResponse(await http.get(Uri.parse(url), headers: headers));
    final codeUnits = response.body.codeUnits;
    final body = Utf8Decoder().convert(codeUnits);
    final List<dynamic> responseJson = jsonDecode(body);
    return responseJson.map((m) =>
        MemberInfo(
          m['id'],
          m['order'],
          m['has_priority'],
          m['is_held'],
          m['joined_at'],
        )
    ).toList();
  }

  Future<UserInfo> getUser(String userId) async {
    final url = '$apiUrl/users/$userId';
    final headers = {'Authorization': 'Bearer $token'};
    final response = throwResponse(await http.get(Uri.parse(url), headers: headers));
    final codeUnits = response.body.codeUnits;
    final body = Utf8Decoder().convert(codeUnits);
    final dynamic r = jsonDecode(body);
    return UserInfo(
      id: r['id'],
      name: r['name'],
    );
  }

  // Получает список доступных очередей от сервера
  // То есть очередей где текущий пользователь участник или администратор
  Future<List<QueueInfo>> getMyQueues() async {
    final url = '$apiUrl/queues';
    final headers = {'Authorization': 'Bearer $token'};
    final response = throwResponse(await http.get(Uri.parse(url), headers: headers));
    final codeUnits = response.body.codeUnits;
    final body = Utf8Decoder().convert(codeUnits);
    final List<dynamic> responseJson = jsonDecode(body);
    return responseJson.map((e) =>
        QueueInfo(
          e['id'],
          e['name'],
          e['description'],
          e['organizer_id'],
          e['created_at'],
          e['exists_before'],
        )
    ).toList();
  }

  // Получает список доступных очередей от сервера
  // То есть очередей где текущий пользователь участник или администратор
  Future<void> removeMemberFromQueue(String queueId, String memberId) async {
    final url = '$apiUrl/queues/$queueId/members/$memberId';
    final headers = {'Authorization': 'Bearer $token'};
    final _response = throwResponse(await http.delete(Uri.parse(url), headers: headers));
    return;
  }

  // Получает список доступных очередей от сервера
  // То есть очередей где текущий пользователь участник или администратор
  Future<void> addMemberToQueue(String queueId, String memberId) async {
    final url = '$apiUrl/queues/$queueId/members/$memberId';
    final headers = {'Authorization': 'Bearer $token'};
    final _response = throwResponse(await http.post(Uri.parse(url), headers: headers));
    return;
  }

  Future<void> deleteQueue(String queueId) async {
    final url = '$apiUrl/queues/$queueId';
    final headers = {'Authorization': 'Bearer $token'};
    final _ = throwResponse(await http.delete(Uri.parse(url), headers: headers));
    return;
  }

  Future<QueueInfo> createQueue(String name, String description) async {
    final url = '$apiUrl/queues';
    final headers = { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json'  };
    final body = {'name': name, 'description': description};
    final response = throwResponse(await http.post(Uri.parse(url), body: jsonEncode(body), headers: headers));
    final codeUnits = response.body.codeUnits;
    final rBody = Utf8Decoder().convert(codeUnits);
    final responseJson = jsonDecode(rBody);
    return QueueInfo(
        responseJson.id,
        responseJson.name,
        responseJson.description,
        responseJson.organizer_id,
        responseJson.created_at,
        responseJson.exists_before,
    );
  }
}

final authApi = AuthApi.fromUrl('http://84.201.154.217:8080');
