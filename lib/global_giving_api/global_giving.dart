import 'dart:convert';

import 'package:altru/altru_donation_interface.dart';
import 'package:http/http.dart';

class AltruGlobalGiving implements AltruDonationInterface {
  static const String API_URL = "api.globalgiving.org/api";
  static const String API_KEY = "c9cbda32-1670-4c24-98ec-c60cc3b468bc";
  static const Map<String, String> REQUEST_HEADER = {
    "Accept": "application/json",
  };

  Client client;

  AltruGlobalGiving({client}) {
    this.client = client != null ? client : Client();
  }

  static AltruRecipient projectJsonToRecipient(projectJson) => AltruRecipient(name: projectJson["title"]);
  static List<AltruRecipient> projectResponseToRecipients(Response response) {
    if (response.statusCode != 200) {
      throw new Exception(response.reasonPhrase);
    }

    var responseJson = json.decode(response.body);
    var projectJson = responseJson["projects"]["project"];

    return projectJson.map<AltruRecipient>(projectJsonToRecipient).toList();
  }

  Future<List<AltruRecipient>> getRecipients(int count) async {
    assert(0 < count && count < 10, "GlobalGiving can only serve up to 10 projects at a time");

    const String PROJECT_URL = "public/projectservice/featured/projects";
    const String API_CALL = "https://$API_URL/$PROJECT_URL?api_key=$API_KEY";

    return this
        .client
        .get(API_CALL, headers: REQUEST_HEADER)
        .then(projectResponseToRecipients)
        .then((recipients) => recipients.sublist(0, count));
  }
}
