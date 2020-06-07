import 'dart:math';

import 'package:altru/altru_donation_interface.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AltruJustGiving implements AltruDonationInterface {
  static const String DEV_URL = "api.staging.justgiving.com";
  static const String PRODUCTION_URL = "api.justgiving.com";
  static const String API_VERSION = "v1";
  static const String APP_ID = "b80764ee";
  static const Map<String, String> REQUEST_HEADER = {
    "x-api-key": APP_ID,
    "Accept": "application/json",
  };

  final String baseUrl;
  http.Client client;

  AltruJustGiving({baseUrl = "$DEV_URL", client}) : this.baseUrl = "$baseUrl/$API_VERSION" {
    this.client = client != null ? client : http.Client();
  }

  static AltruRecipient charityJsonToRecipient(charityJson) => AltruRecipient(name: charityJson["Name"]);
  static List<AltruRecipient> charityResponseToRecipients(http.Response response) {
    if (response.statusCode != 200) {
      throw new Exception(response.reasonPhrase);
    }

    var responseJson = json.decode(response.body);
    var charityResponse = responseJson["GroupedResults"][0]["Results"];

    return charityResponse.map<AltruRecipient>(charityJsonToRecipient).toList();
  }

  Future<http.Response> _request(String apiCall, Map<String, String> queryStringMap) {
    String queryString = queryStringMap.entries.map((entry) => "${entry.key}=${entry.value}").join("&");
    String searchUrl = "https://$baseUrl/$apiCall?$queryString";

    return client.get(searchUrl, headers: REQUEST_HEADER);
  }

  Future<List<AltruRecipient>> getRecipients(int count) async {
    assert(count > 0, "Must ask for at least one recipient");

    return _request("onesearch", {
      "i": "Charity",
      "limit": max(0, count).toString(),
    }).then(charityResponseToRecipients);
  }

  void close() => this.client.close();
}
