import 'package:flutter/material.dart';
import 'package:rasajogja_mobile/screens/auth/login.dart';
import 'package:rasajogja_mobile/screens/auth/register.dart';
import 'package:rasajogja_mobile/screens/firstpage.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  PageController controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3, // FirstPage, LoginPage, RegisterPage
        controller: controller,
        itemBuilder: (context, index) {
          if (index == 0) {
            return FirstPage(); // FirstPage sebagai halaman pertama
          } else if (index == 1) {
            return LoginPage(controller: controller); // LoginPage
          } else if (index == 2) {
            return RegisterPage(controller: controller); // RegisterPage
          }
          return null;
        },
      ),
    );
  }
}
