import 'dart:convert';
import 'dart:io';
import 'package:flutter_recipe_generator/gemini_model/gemini_util.dart';
import 'package:http/http.dart' as http;

Future<String> convertImageToBase64(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  String base64String = base64Encode(bytes);

  return base64String;
}

Future<void> sendAndAnalyzeWithGemini(List<String> base64Images,
    Function(String) onSuccess, Function(String) onFailed) async {
  final String baseUrl = GeminiData.url;

  final Map<String, String> queryParams = {"key": GeminiData.apikey};

  final Uri url = Uri.parse(baseUrl).replace(queryParameters: queryParams);

  final List<Map<String, dynamic>> inlineDataList = base64Images.map((img) {
    return {
      "inlineData": {
        "mimeType": "image/jpg",
        "data": img,
      }
    };
  }).toList();

  final Map<String, dynamic> body = {
    "contents": [
      {
        "parts": [
          {"text": GeminiData.prompt},
          ...inlineDataList,
        ]
      }
    ]
  };

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      onSuccess(response.body);
    } else {
      onFailed("Error: ${response.statusCode}, ${response.body}");
    }
  } catch (e) {
    onFailed(e.toString());
  }
}

String extractResponse(String response) {
  final Map<String, dynamic> jsonResponse = jsonDecode(response);

  final String partText =
      jsonResponse["candidates"][0]["content"]["parts"][0]["text"];

  return partText;
}
