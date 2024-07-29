import 'package:flutter/material.dart';
import 'package:oua_notes_app/auth/auth_service.dart';
import 'package:oua_notes_app/components/my_button.dart';
import 'package:oua_notes_app/components/my_textfield.dart';
import 'package:oua_notes_app/pages/home_page.dart';

class LoginPage extends StatelessWidget {
  // email and pw text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  //tap to go register page
  final void Function()? onTap;
  LoginPage({
    super.key,
    required this.onTap,
  });
  // login mehod
  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();
    // try login
    try {
      await authService.signInWithEmailAndPassword(
          _emailController.text, _pwController.text);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              HomePage(), // HomePage yerine açmak istediğiniz sayfanın adını kullanın
        ),
      );
    }
    // catch any errors
    catch (e) {
      // Hata mesajını konsola yazdırın
      print("Giriş Hatası: $e");

      // Hata mesajını kullanıcıya göstermek için dialog kullanabilirsiniz
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Giriş Hatası"),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              child: Text("Tamam"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //logo
          Icon(
            Icons.message,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(
            height: 50,
          ),
          //welcome back message
          Text(
            "Hoşgeldin, seni özledik",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
            ),
          ),
          //email textfield
          const SizedBox(
            height: 25,
          ),
          MyTextField(
            hintText: "Email",
            obscureText: false,
            controller: _emailController,
          ),
          const SizedBox(
            height: 10,
          ),
          //pw textfield
          MyTextField(
            hintText: "Şifre",
            obscureText: true,
            controller: _pwController,
          ),
          const SizedBox(
            height: 25,
          ),

          //login button
          MyButton(
            text: "Login",
            onTap: () => login(context),
          ),
          const SizedBox(
            height: 25,
          ),

          //register now
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Üye değil misin?",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  "Şimdi üye ol",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

