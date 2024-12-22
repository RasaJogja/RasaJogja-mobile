import 'package:flutter/material.dart';
import 'package:rasajogja_mobile/screens/auth/login.dart';
import 'package:rasajogja_mobile/screens/auth/register.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB79375),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Memperbesar ukuran logo
            Image.asset(
              "assets/images/logo_rasajogja.png",
              width: 200, // Ukuran logo diperbesar
              height: 200, // Ukuran logo diperbesar
            ),
            const SizedBox(height: 20),
            // Menurunkan ukuran teks dan mengubah font menjadi font tulis sambung
            const Text(
              'RasaJogja',
              style: TextStyle(
                fontSize: 30, // Ukuran teks sedikit lebih kecil
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'DancingScript', // Menggunakan font tulis sambung
              ),
            ),
            const Text(
              '"Jogja dalam satu rasa"',
              style: TextStyle(
                fontSize: 14, // Ukuran teks sedikit lebih kecil
                fontStyle: FontStyle.italic,
                color: Colors.white,
                fontFamily: 'Poppins', // Menggunakan font biasa
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(controller: PageController()),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB79375),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // Pass PageController() to RegisterPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RegisterPage(controller: PageController()),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Register',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB79375),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
