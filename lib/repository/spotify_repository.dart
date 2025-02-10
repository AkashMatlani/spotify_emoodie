import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyRepository {
  static final SpotifyRepository _instance = SpotifyRepository._internal();
  final Dio _dio = Dio();
  String? _accessToken;
  DateTime? _tokenExpiration;

  factory SpotifyRepository() => _instance; // Singleton instance

  SpotifyRepository._internal() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_accessToken == null ||
            _tokenExpiration == null ||
            DateTime.now().isAfter(_tokenExpiration!)) {
          await _refreshAccessToken();
        }
        options.headers['Authorization'] = 'Bearer $_accessToken';
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await _refreshAccessToken();
          e.requestOptions.headers['Authorization'] = 'Bearer $_accessToken';
          return handler.resolve(await _dio.fetch(e.requestOptions));
        }
        return handler.next(e);
      },
    ));
  }

  Future<String> _refreshAccessToken() async {
    if (_accessToken != null &&
        _tokenExpiration != null &&
        DateTime.now().isBefore(_tokenExpiration!)) {
      return _accessToken!;
    }

    try {
      String clientId = dotenv.env['CLIENT_ID'] ?? '';
      String clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';
      final response = await Dio().post(
        'https://accounts.spotify.com/api/token',
        options: Options(headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        }),
        data: {'grant_type': 'client_credentials'},
      );

      _accessToken = response.data['access_token'];
      _tokenExpiration =
          DateTime.now().add(Duration(seconds: response.data['expires_in']));
      return _accessToken!;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching access token: $e");
      }
      return '';
    }
  }

  Future<Response> search(String query, String type) async {
    return _dio.get(
      'https://api.spotify.com/v1/search',
      queryParameters: {'q': query, 'type': type},
    );
  }
}
