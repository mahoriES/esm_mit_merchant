import 'package:foore/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:foore/data/bloc/auth.dart';

class HttpService {
  String apiUrl = 'https://www.api.test.foore.io/api/v1/';

  AuthBloc _authBloc;

  HttpService(AuthBloc authBloc) {
    this._authBloc = authBloc;
    this.apiUrl =  Environment.apiUrl;
  }

  Future<http.Response> get(url, {Map<String, String> headers}) =>
      http.get(url, headers: headers);

  Future<http.Response> foGet(url) async {
    if (this._authBloc.authState.authData != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT ${this._authBloc.authState.authData.token}'
      };

      final httpResponse =
          await http.get(apiUrl + url, headers: requestHeaders);

      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        // If the call to the server was successful, parse the JSON.
        return httpResponse;
      }
      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.logout();
        throw Exception('Auth Failed');
      } else {
        print(httpResponse.toString());

        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } else {
      this._authBloc.logout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> foPost(url, body) async {
    if (this._authBloc.authState.authData != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT ${this._authBloc.authState.authData.token}'
      };
      final httpResponse =
          await http.post(apiUrl + url, headers: requestHeaders, body: body);
      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.logout();
        throw Exception('Auth Failed');
      }
      return httpResponse;
    } else {
      this._authBloc.logout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> foPostWithoutAuth(url, body) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final httpResponse =
        await http.post(apiUrl + url, headers: requestHeaders, body: body);
    return httpResponse;
  }

  Future<http.Response> foGetWithoutAuth(url) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final httpResponse =
        await http.get(apiUrl + url, headers: requestHeaders);
    return httpResponse;
  }

  Future<http.Response> foPostUrl(url, body) async {
    if (this._authBloc.authState.authData != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT ${this._authBloc.authState.authData.token}'
      };
      final httpResponse =
          await http.post(url, headers: requestHeaders, body: body);
      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.logout();
        throw Exception('Auth Failed');
      }
      return httpResponse;
    } else {
      this._authBloc.logout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> foGetUrl(url) async {
    if (this._authBloc.authState.authData != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT ${this._authBloc.authState.authData.token}'
      };

      final httpResponse = await http.get(url, headers: requestHeaders);

      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.logout();
        throw Exception('Auth Failed');
      }
      return httpResponse;
    } else {
      this._authBloc.logout();
      throw Exception('Auth Failed');
    }
  }
}
