import 'dart:convert';

import 'package:altru/altru_donation_interface.dart';
import 'package:altru/global_giving_api/global_giving.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

getSuccessfulResponse(recipientJson) {
  return http.Response(
      json.encode({
        "projects": {"project": recipientJson}
      }),
      200);
}

getSimpleProjectJson() {
  return List.generate(10, (index) => {"title": "Project ${index + 1}", "id": index});
}

void main() {
  group("Test Get Recipients", () {
    test("When API call response is bad, throws exception", () async {
      String exampleResponseReason = "Example Error";

      MockClient mockClient = MockClient((request) async {
        if (request.url.toString().contains("projects")) {
          return http.Response(exampleResponseReason, 404);
        } else
          return http.Response("{}", 200);
      });
      AltruGlobalGiving api = AltruGlobalGiving(client: mockClient);

      try {
        await api.getRecipients(5);
        fail("Bad API response should throw an exception");
      } catch (error) {
        expect(error, isInstanceOf<Exception>());
      }
    });

    test("Respects the count in the API call", () async {
      int recipientCount = 5;

      MockClient mockClient = MockClient((request) async => getSuccessfulResponse(getSimpleProjectJson()));

      AltruGlobalGiving api = AltruGlobalGiving(client: mockClient);

      expect((await api.getRecipients(recipientCount)).length, recipientCount);
    });

    test("When user asks for an unreasonable number of recipients, throws exception", () async {
      MockClient mockClient = MockClient((request) async => http.Response("{}", 200));

      AltruGlobalGiving api = AltruGlobalGiving(client: mockClient);

      for (int recipientCount in [0, -1000, 11]) {
        expect(api.getRecipients(recipientCount), throwsAssertionError);
      }
    });

    test("Correctly formats response into a list of AltruRecipients", () async {
      int recipientCount = 5;
      List<AltruRecipient> expectedRecipients = List<AltruRecipient>.generate(
          recipientCount, (index) => AltruRecipient(id: index, name: "Project ${index + 1}"));

      MockClient mockClient = MockClient((request) async => getSuccessfulResponse(getSimpleProjectJson()));

      AltruGlobalGiving api = AltruGlobalGiving(client: mockClient);

      expect(listEquals(await api.getRecipients(recipientCount), expectedRecipients), true);
    });
  });
}
