import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasajogja_mobile/widgets/left_drawer.dart';
import 'package:rasajogja_mobile/models/katalog/katalog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class ProductEntryPage extends StatefulWidget {
  const ProductEntryPage({super.key});

  @override
  State<ProductEntryPage> createState() => _ProductEntryPageState();
}

class _ProductEntryPageState extends State<ProductEntryPage>
  
  with SingleTickerProviderStateMixin {
  String selectedCategory = 'All';
  bool sortAscending = true;
  String searchQuery = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String categoryToString(Kategori kategori) {
    switch (kategori) {
      case Kategori.MAKANAN:
        return 'Makanan';
      case Kategori.MINUMAN:
        return 'Minuman';
      case Kategori.CAMILAN:
        return 'Camilan';
      case Kategori.MAKANAN_PENUTUP:
        return 'Makanan Penutup';
    }
  }

  Kategori? stringToCategory(String value) {
    switch (value) {
      case 'Makanan':
        return Kategori.MAKANAN;
      case 'Minuman':
        return Kategori.MINUMAN;
      case 'Camilan':
        return Kategori.CAMILAN;
      case 'Makanan Penutup':
        return Kategori.MAKANAN_PENUTUP;
      default:
        return null;
    }
  }

  Future<void> addBookmark(int productId, int userId) async {
  final url = Uri.parse('http://127.0.0.1:8000/add_flutter/$productId/');
  
  // Data yang dikirimkan
  final body = {'user_id': userId.toString()};
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    // Cek status response
    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('Bookmark added: ${responseData['message']}');
    } else if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Bookmark already exists: ${responseData['message']}');
    } else {
      print('Error: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('Exception occurred: $e');
    }
  }
  Future<List<KatalogResponse>> fetchProduct(CookieRequest request) async {
    final response =
        await request.get('http://127.0.0.1:8000/katalog/view_json/');
    var data = response['products'];

    List<KatalogResponse> listProduct = [];
    for (var d in data) {
      if (d != null) {
        listProduct.add(KatalogResponse.fromJson(d));
      }
    }
    return listProduct;
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                        value: 'All', child: Text('All Categories')),
                    ...Kategori.values.map((kategori) => DropdownMenuItem(
                          value: categoryToString(kategori),
                          child: Text(categoryToString(kategori)),
                        )),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedCategory = value!),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: colorScheme.primary,
              ),
              onPressed: () => setState(() => sortAscending = !sortAscending),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(KatalogResponse product) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'product-${product.pk}',
                      child: Image.network(
                        product.fields.urlGambar,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.fields.nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rp ${product.fields.harga.toString().replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]}.',
                                )}',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                              Icons.restaurant, product.fields.namaRestoran),
                          const SizedBox(height: 4),
                          _buildInfoRow(
                              Icons.location_on, product.fields.lokasi),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categoryToString(product.fields.kategori),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                 Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      color: colorScheme.primary,
                      onPressed: () async {
                        final userId = 1; // Ganti dengan ID pengguna yang sesuai
                        await addBookmark(product.pk, userId);
                      },
                    ),
                  ),
                 ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Foods'),
        backgroundColor: colorScheme.primary,
        elevation: 0,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterSection(),
          Expanded(
            child: FutureBuilder(
              future: fetchProduct(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingShimmer();
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return _buildEmptyState();
                } else {
                  List products = snapshot.data;

                  // Apply filters
                  if (selectedCategory != 'All') {
                    products = products
                        .where((p) =>
                            p.fields.kategori ==
                            stringToCategory(selectedCategory))
                        .toList();
                  }
                  if (searchQuery.isNotEmpty) {
                    products = products
                        .where((p) => p.fields.nama
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();
                  }

                  // Sort
                  products.sort((a, b) => sortAscending
                      ? a.fields.harga.compareTo(b.fields.harga)
                      : b.fields.harga.compareTo(a.fields.harga));

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width ~/ 280,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) =>
                        _buildProductCard(products[index]),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width ~/ 280,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: colorScheme.secondary),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 20,
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
