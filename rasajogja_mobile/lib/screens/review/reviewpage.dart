import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'add_review_page.dart';

class ReviewPage extends StatefulWidget {
  final int productId;
  final String productName;

  const ReviewPage({
    Key? key, 
    required this.productId,
    required this.productName,
  }) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late Future<List<dynamic>> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = fetchReviews();
  }

  Future<List<dynamic>> fetchReviews() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'http://localhost:8000/review/flutter/${widget.productId}/',
    );
    return response['reviews'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.productName} Reviews'),
        backgroundColor: const Color(0xFFAB886D),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _reviews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final reviews = snapshot.data!;
                
                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index]['fields'];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(review['username']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review['review_text']),
                            Text(
                              review['time'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAB886D),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddReviewPage(
                          productId: widget.productId,
                        ),
                      ),
                    ).then((_) {
                      setState(() {
                        _reviews = fetchReviews();
                      });
                    });
                  },
                  child: const Text('Add Review'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAB886D),
                  ),
                  onPressed: () {
                    // Bookmark functionality will be implemented later
                  },
                  child: const Text('Bookmark'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
