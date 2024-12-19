import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasajogja_mobile/widgets/left_drawer.dart';
import 'package:rasajogja_mobile/screens/katalog/product_entry.dart';

class ProductEntryPage extends StatefulWidget {
  const ProductEntryPage({super.key});

  @override
  State<ProductEntryPage> createState() => _ProductEntryPageState();
}

class _ProductEntryPageState extends State<ProductEntryPage> {
  String selectedCategory = 'All';
  bool sortAscending = true;

  Future<List<Welcome>> fetchProduct(CookieRequest request) async {
    final response =
        await request.get('http://127.0.0.1:8000/katalog/view_json/');
    var data = response['products'];

    List<Welcome> listProduct = [];
    for (var d in data) {
      if (d != null) {
        listProduct.add(Welcome.fromJson(d));
      }
    }
    return listProduct;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Entry List'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                    DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
                    DropdownMenuItem(value: 'Camilan', child: Text('Camilan')),
                    DropdownMenuItem(
                        value: 'Makanan Penutup',
                        child: Text('Makanan Penutup')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 16),
                ),
                Row(
                  children: [
                    const Text(
                      'Sort by Price:',
                      style: TextStyle(fontSize: 14),
                    ),
                    IconButton(
                      icon: Icon(
                        sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () {
                        setState(() {
                          sortAscending = !sortAscending;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchProduct(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  );
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada data Product di RasaJogja.',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  );
                } else {
                  List products = snapshot.data;

                  // Filter by category
                  if (selectedCategory != 'All') {
                    products = products
                        .where((product) =>
                            product.fields.kategori.toString().toLowerCase() ==
                            selectedCategory.toLowerCase())
                        .toList();
                  }

                  // Sort by price
                  products.sort((a, b) => sortAscending
                      ? a.fields.harga.compareTo(b.fields.harga)
                      : b.fields.harga.compareTo(a.fields.harga));

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final product = products[index].fields;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Image.network(
                                      product.urlGambar,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.broken_image,
                                            size: 50, color: Colors.grey),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          product.kategori
                                              .toString()
                                              .replaceAll('kategori.', '') // Hapus prefix
                                              .replaceAll('_', ' ') // Ganti underscore
                                              .toLowerCase()
                                              .split(' ') // Split kata
                                              .map((word) => word[0]
                                                      .toUpperCase() +
                                                  word.substring(1)) // Kapitalisasi
                                              .join(' '), // Gabungkan kembali
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.nama,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp ${product.harga}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.restaurant,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              product.namaRestoran,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 14, color: Colors.red),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              product.lokasi,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
