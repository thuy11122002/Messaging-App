import 'package:flutter/material.dart';
import 'package:messager_app/main.dart';
import 'package:messager_app/service/auth_service.dart';
import 'package:messager_app/view/home_page.dart';
import 'package:messager_app/view/login_page.dart';
import 'package:messager_app/view/widgets/snackBar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _usernameController = TextEditingController();

  bool isLoadin = false;

  void _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String username = _usernameController.text.trim();

    if (!email.contains(".com")) {
      showSnackBar(context, "Email is invalid, it must contain .com");
    }
    if (username.isEmpty || username.length < 8) {
      showSnackBar(
          context, "Username is invalid, it must be more than 8 characters");
    }

    setState(() {
      isLoadin = true;
    });

    final result = await _authService.signUp(email, password, username);

    if (result == "Success") {
      setState(() {
        isLoadin = false;
      });
      showSnackBar(context, "Sign up success, Loading...");
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => MyHomePage()));
    } else {
      setState(() {
        isLoadin = false;
      });
      showSnackBar(context, "Sign up fail: $result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 80),
              Text("Sign Up",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 32,
                      color: Color.fromRGBO(109, 76, 146, 1),
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 40),
              TextFormField(
                controller: _usernameController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || !value.contains('@')
                    ? "Enter a valid email"
                    : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                style: TextStyle(color: Colors.black),
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Password", border: OutlineInputBorder()),
                validator: (value) => value == null || value.length < 6
                    ? "Password too short"
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _signUp(),
                child: isLoadin ? CircularProgressIndicator() : Text("Sign Up"),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                child: Text("Already have an account? Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
