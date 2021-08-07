import 'dart:convert';

// external packages
import 'package:http/http.dart' as http;

class ApiController {
  Future<dynamic> login({url, body}) async {
    var postData = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
    );
    return postData;
  }

  static Future getStationCoords({url, accessKey}) async {
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': accessKey,
      },
    );

    return response;
  }
}
