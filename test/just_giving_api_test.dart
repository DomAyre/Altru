import 'dart:convert';

import 'package:altru/altru_donation_interface.dart';
import 'package:altru/just_giving_api/just_giving.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group("Test Get Recipients", () {
    test("When API call response is bad, throws exception", () async {
      String exampleResponseReason = "Example Error";

      MockClient mockClient = MockClient();
      when(mockClient.get(anything, headers: anyNamed("headers")))
          .thenAnswer((_) async => http.Response(exampleResponseReason, 404));
      AltruJustGiving api = AltruJustGiving(baseUrl: AltruJustGiving.DEV_URL, client: mockClient);

      expect(api.getRecipients(5), throwsException);
    });

    test("Respects the count in the API call", () async {
      int recipientCount = 5;
      MockClient mockClient = MockClient();
      when(mockClient.get(anything, headers: anyNamed("headers"))).thenAnswer((_) async => http.Response(
          json.encode({
            "GroupedResults": [
              {"Results": []}
            ]
          }),
          200));
      AltruJustGiving api = AltruJustGiving(baseUrl: AltruJustGiving.DEV_URL, client: mockClient);

      await api.getRecipients(recipientCount);

      verify(mockClient.get(
              argThat(equals("https://api.staging.justgiving.com/v1/onesearch?i=Charity&limit=$recipientCount")),
              headers: anyNamed("headers")))
          .called(greaterThan(0));
    });

    test("When user asks for an unreasonable number of recipients, throws exception", () async {
      MockClient mockClient = MockClient();
      AltruJustGiving api = AltruJustGiving(baseUrl: AltruJustGiving.DEV_URL, client: mockClient);

      for (int recipientCount in [0, -1000]) {
        expect(api.getRecipients(recipientCount), throwsAssertionError);
      }
    });

    test("Correctly formats response into a list of AltruRecipients", () async {
      int recipientCount = 5;
      MockClient mockClient = MockClient();
      when(mockClient.get(anything, headers: anyNamed("headers"))).thenAnswer((_) async => http.Response(
          json.encode({
            "GroupedResults": [
              {
                "Results":
                    List<Map<String, String>>.generate(recipientCount, (index) => {"Name": "Charity ${index + 1}"})
              }
            ]
          }),
          200));
      AltruJustGiving api = AltruJustGiving(baseUrl: AltruJustGiving.DEV_URL, client: mockClient);

      expect(
          listEquals(await api.getRecipients(recipientCount),
              List<AltruRecipient>.generate(recipientCount, (index) => AltruRecipient(name: "Charity ${index + 1}"))),
          true);
    });
  });
}
