import 'package:flutter/material.dart';
import '../services/quotes_api_service.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  String quote = "";
  String author = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    setState(() => isLoading = true);

    try {
      final data = await QuotesApiService().getRandomQuote();

      setState(() {
        quote = data["quote"] ?? "";
        author = data["author"] ?? "";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        quote = "Failed to load quote 😢";
        author = "";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Quotes",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.format_quote,
                              size: 50,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 15),

                            Text(
                              '"$quote"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                author.isEmpty ? "" : "- $author",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            SizedBox(
                              width: 160,
                              child: ElevatedButton.icon(
                                onPressed: fetchQuote,
                                icon: const Icon(Icons.refresh),
                                label: const Text("New Quote"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
