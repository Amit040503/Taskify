import 'dart:convert';
import 'package:http/http.dart' as http;

class QuotesApiService {
  // ZenQuotes Random Quote
  Future<Map<String, String>> getRandomQuote() async {
    final url = Uri.parse("https://zenquotes.io/api/random");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return {"quote": data[0]["q"], "author": data[0]["a"]};
    } else {
      throw Exception("Failed to load quote");
    }
  }
}
