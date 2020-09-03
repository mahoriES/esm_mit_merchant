import 'package:foore/data/bloc/analytics.dart';
import 'package:foore/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:foore/data/bloc/auth.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'dart:async';

class HttpService {
  String apiUrl = 'https://www.api.foore.io/api/v1/';

  String esApiBaseUrl = 'https://api.test.esamudaay.com/api/v1/';

  AuthBloc _authBloc;

  HttpService(AuthBloc authBloc) {
    this._authBloc = authBloc;
    this.apiUrl = Environment.apiUrl;
    this.esApiBaseUrl = Environment.esApiUrl;
  }

  FoAnalytics get foAnalytics {
    return this._authBloc.foAnalytics;
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
    final httpResponse = await http.get(apiUrl + url, headers: requestHeaders);
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

  // eSamudaay
  Future<http.Response> esGet(path) async {
    final esJwtToken = this._authBloc.authState.esMerchantJwtToken;
    if (esJwtToken != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT $esJwtToken'
      };

      final httpResponse =
          await http.get(esApiBaseUrl + path, headers: requestHeaders);

      print(httpResponse.request.url.toString());
      print(httpResponse.statusCode);
      print(httpResponse.body);

      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        // If the call to the server was successful, parse the JSON.
        return httpResponse;
      }
      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.esLogout();
        throw Exception('Auth Failed');
      } else {
        print(httpResponse.toString());

        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } else {
      this._authBloc.esLogout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> esGetWithToken(path, token) async {
    if (token != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT $token'
      };

      final httpResponse =
          await http.get(esApiBaseUrl + path, headers: requestHeaders);

      print(httpResponse.request.url.toString());
      print(httpResponse.statusCode);
      print(httpResponse.body);

      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        // If the call to the server was successful, parse the JSON.
        return httpResponse;
      }
      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.esLogout();
        throw Exception('Auth Failed');
      } else {
        print(httpResponse.toString());

        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } else {
      this._authBloc.esLogout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> esPost(path, body) async {
    final esJwtToken = this._authBloc.authState.esMerchantJwtToken;
    if (esJwtToken != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT $esJwtToken'
      };
      final httpResponse = await http.post(esApiBaseUrl + path,
          headers: requestHeaders, body: body);

      print(httpResponse.request.url.toString());
      print(httpResponse.statusCode);
      print(httpResponse.body);

      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.esLogout();
        throw Exception('Auth Failed');
      }
      return httpResponse;
    } else {
      this._authBloc.esLogout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> esPostWithToken(path, body, token) async {
    if (token != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT $token'
      };
      final httpResponse = await http.post(esApiBaseUrl + path,
          headers: requestHeaders, body: body);

      print(httpResponse.request.url.toString());
      print(httpResponse.statusCode);
      print(httpResponse.body);

      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.esLogout();
        throw Exception('Auth Failed');
      }
      return httpResponse;
    } else {
      this._authBloc.esLogout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> esPatch(path, body) async {
    final esJwtToken = this._authBloc.authState.esMerchantJwtToken;
    if (esJwtToken != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT $esJwtToken'
      };
      final httpResponse = await http.patch(esApiBaseUrl + path,
          headers: requestHeaders, body: body);
      print(body);
      print(httpResponse.request.url.toString());
      print(httpResponse.statusCode);
      print(httpResponse.body);

      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.esLogout();
        throw Exception('Auth Failed');
      }
      return httpResponse;
    } else {
      this._authBloc.esLogout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> esPut(path, body) async {
    final esJwtToken = this._authBloc.authState.esMerchantJwtToken;
    if (esJwtToken != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT $esJwtToken'
      };
      final httpResponse = await http.put(esApiBaseUrl + path,
          headers: requestHeaders, body: body);

      print(body);
      print(httpResponse.request.url.toString());
      print(httpResponse.statusCode);
      print(httpResponse.body);

      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.esLogout();
        throw Exception('Auth Failed');
      }
      return httpResponse;
    } else {
      this._authBloc.esLogout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> esDel(path) async {
    final esJwtToken = this._authBloc.authState.esMerchantJwtToken;
    if (esJwtToken != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT $esJwtToken'
      };
      final httpResponse =
          await http.delete(esApiBaseUrl + path, headers: requestHeaders);
      print(httpResponse.request.url.toString());
      print(httpResponse.statusCode);
      print(httpResponse.body);

      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.esLogout();
        throw Exception('Auth Failed');
      }
      return httpResponse;
    } else {
      this._authBloc.esLogout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> esPostWithoutAuth(path, body) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final httpResponse = await http.post(esApiBaseUrl + path,
        headers: requestHeaders, body: body);

    print(httpResponse.request.url.toString());
    print(httpResponse.statusCode);
    print(httpResponse.body);

    return httpResponse;
  }

  Future<http.Response> esGetWithoutAuth(path) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final httpResponse =
        await http.get(esApiBaseUrl + path, headers: requestHeaders);

    print(httpResponse.request.url.toString());
    print(httpResponse.statusCode);
    print(httpResponse.body);
    return httpResponse;
  }

  Future<http.Response> esPostUrl(url, body) async {
    final esJwtToken = this._authBloc.authState.esMerchantJwtToken;
    if (esJwtToken != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT $esJwtToken'
      };
      final httpResponse =
          await http.post(url, headers: requestHeaders, body: body);

      print(httpResponse.request.url.toString());
      print(httpResponse.statusCode);
      print(httpResponse.body);

      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.esLogout();
        throw Exception('Auth Failed');
      }
      return httpResponse;
    } else {
      this._authBloc.esLogout();
      throw Exception('Auth Failed');
    }
  }

  Future<http.Response> esGetUrl(url) async {
    final esJwtToken = this._authBloc.authState.esMerchantJwtToken;
    if (esJwtToken != null) {
      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT $esJwtToken'
      };

      final httpResponse = await http.get(url, headers: requestHeaders);

      print(httpResponse.request.url.toString());
      print(httpResponse.statusCode);
      print(httpResponse.body);

      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.esLogout();
        throw Exception('Auth Failed');
      }
      return httpResponse;
    } else {
      this._authBloc.esLogout();
      throw Exception('Auth Failed');
    }
  }

  esUpload(path, File imageFile) async {
    final esJwtToken = this._authBloc.authState.esMerchantJwtToken;
    if (esJwtToken != null) {
      Map<String, String> requestHeaders = {
        // 'Content-type': 'application/json',
        // 'Accept': 'application/json',
        'Authorization': 'JWT $esJwtToken'
      };
      var stream =
          new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      var length = await imageFile.length();

      var uri = Uri.parse(esApiBaseUrl + path);

      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(requestHeaders);
      var multipartFile = new http.MultipartFile('file', stream, length,
          filename: basename(imageFile.path));
      //contentType: new MediaType('image', 'png'));

      request.files.add(multipartFile);
      var httpResponse = await request.send();
      //Get the response from the server

      if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
        this._authBloc.esLogout();
        throw Exception('Auth Failed');
      } else if (httpResponse.statusCode == 200) {
        var responseData = await httpResponse.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        print(responseString);
        return responseString;
      } else {
        throw Exception('Failed');
      }
    } else {
      this._authBloc.esLogout();
      throw Exception('Auth Failed');
    }
  }
}
