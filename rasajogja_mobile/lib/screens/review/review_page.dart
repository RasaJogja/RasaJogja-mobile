import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'add_review_page.dart';
import '../../models/review/review_entry.dart';

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
  late Future<ReviewResponse> _reviews;
  bool _isNewestFirst = true;  // Add this line

  Future<void> addBookmark(int productId) async {
  final url = Uri.parse('http://127.0.0.1:8000/bookmark/add_flutter/$productId/');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('Bookmark added: ${responseData['message']}');
    } else if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Bookmark already exists: ${responseData['message']}');
    } else {
      throw Exception('Error: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('Exception occurred: $e');
    rethrow; // Lempar ulang error untuk ditangani di UI
  }
}


  // Tambahkan fungsi deleteReview
  Future<void> deleteReview(int reviewId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8000/review/api/review/$reviewId/delete/')
    );
    
    if (response.statusCode == 200) {
      // Jika berhasil, perbarui daftar review dengan memuat ulang
      setState(() {
        _reviews = fetchReviews();
      });
    } else {
      // Tampilkan pesan error jika penghapusan gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete review')),
      );
    }
  }



  @override
  void initState() {
    super.initState();
    _reviews = fetchReviews();
  }

  Future<ReviewResponse> fetchReviews() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'http://localhost:8000/review/api/product/${widget.productId}/reviews/',
    );
    return ReviewResponse.fromJson(response);
  }

  List<Review> _sortReviews(List<Review> reviews) {
    return List<Review>.from(reviews)
      ..sort((a, b) => _isNewestFirst
          ? b.time.compareTo(a.time)
          : a.time.compareTo(b.time));
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
        '${widget.productName} Reviews',
        style: const TextStyle(color: Colors.white), // Warna teks putih
        ),
        backgroundColor: const Color(0xFFAB886D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
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
                      child: const Text('Add Review',
                      style: TextStyle(color: Colors.white), 
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAB886D),
                      ),
                      onPressed: () async {
                        try {
                          await addBookmark(widget.productId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bookmark added successfully!'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add bookmark: $e'),
                            ),
                          );
                        }
                      },
                      child: const Text('Bookmark',
                      style: TextStyle(color: Colors.white), 
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isNewestFirst = !_isNewestFirst;
                    });
                  },
                  icon: Icon(
                    _isNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                    color: const Color(0xFFAB886D),
                  ),
                  label: Text(
                    _isNewestFirst ? 'Newest First' : 'Oldest First',
                    style: const TextStyle(color: Color(0xFFAB886D)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<ReviewResponse>(
              future: _reviews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data!.reviews.isEmpty) {
                  return const Center(child: Text('No reviews yet'));
                }

                final sortedReviews = _sortReviews(snapshot.data!.reviews);
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: sortedReviews.length,
                  itemBuilder: (context, index) {
                    final review = sortedReviews[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  review.time.toString().split('.')[0],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8), // Jarak antara Row di atas dan teks review
                            Text(
                              review.reviewText,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 16), // Jarak antara teks review dan tombol delete
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end, // Memindahkan tombol ke kanan
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFAB886D),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    deleteReview(review.id);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white, // Teks putih
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}