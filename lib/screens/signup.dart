// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darkmodetoggle/apis/api.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  late String name, email, password;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late ScaffoldMessengerState scaffoldMessenger;
  var reg = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 13,
                    ),
                    Text(
                      "Learn With Us",
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              fontSize: 27,
                              color: Colors.white,
                              letterSpacing: 1)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: 180,
                      child: Text(
                        "RRTutors, Hyderabad",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              color: Colors.white54,
                              letterSpacing: 0.6,
                              fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Sign Up",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          letterSpacing: 1,
                          fontSize: 23,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Learn new Technologies 😋",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              color: Colors.white70,
                              letterSpacing: 1,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Form(
                      key: _formKey,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 45),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              controller: _nameController,
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                hintText: "Name",
                                hintStyle: TextStyle(
                                    color: Colors.white70, fontSize: 15),
                              ),
                              onSaved: (val) {
                                name = val!;
                              },
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              controller: _emailController,
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                hintText: "Email",
                                hintStyle: TextStyle(
                                    color: Colors.white70, fontSize: 15),
                              ),
                              onSaved: (val) {
                                email = val!;
                              },
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              obscureText: true,
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                hintText: "Password",
                                hintStyle: TextStyle(
                                    color: Colors.white70, fontSize: 15),
                              ),
                              onSaved: (val) {
                                password = val!;
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Stack(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 0),
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      if (isLoading) {
                                        return;
                                      }
                                      if (_nameController.text.isEmpty) {
                                        scaffoldMessenger.showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text("Please Enter Name")));
                                        return;
                                      }
                                      if (!reg
                                          .hasMatch(_emailController.text)) {
                                        scaffoldMessenger.showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text("Enter Valid Email")));
                                        return;
                                      }
                                      if (_passwordController.text.isEmpty ||
                                          _passwordController.text.length < 6) {
                                        scaffoldMessenger.showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Password should be min 6 characters")));
                                        return;
                                      }
                                      signup(
                                          _nameController.text,
                                          _emailController.text,
                                          _passwordController.text);
                                    },
                                    child: Text(
                                      "CREATE ACCOUNT",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              letterSpacing: 1)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  child: (isLoading)
                                      ? const Center(
                                          child: SizedBox(
                                              height: 26,
                                              width: 26,
                                              child: CircularProgressIndicator(
                                                backgroundColor: Colors.green,
                                              )))
                                      : Container(),
                                  right: 30,
                                  bottom: 0,
                                  top: 0,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "/signin");
                      },
                      child: Text(
                        "Already have an account?",
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                letterSpacing: 0.5)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  signup(name, email, password) async {
    setState(() {
      isLoading = true;
    });
    print("Calling");

    Map<String, String> data = {
      'email': email,
      'password': password,
      'username': name
    };
    print(data);
    final response = await http.post(Uri.parse(registration),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "TOKEN d086ee50d219f3c1f93a32b462d7bb8da1c7e0d6"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"));
    print(response.body);
    if (response.statusCode == 201) {
      setState(() {
        isLoading = false;
      });
      Map<String, dynamic> resposne = jsonDecode(response.body);
      print(response.body);
      if (!resposne.containsKey('error')) {
        Map<String, dynamic> user = resposne;
        print(" User name ${user['data']}");
        savePref(1, user['username'], user['email']);
        Navigator.pushReplacementNamed(context, "/signin");
      } else {
        print(" ${resposne['message']}");
      }
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Account created, please log in!")));
    } else {
      print(response.statusCode);
      Navigator.pushNamed(context, "/signup");
      scaffoldMessenger
          .showSnackBar(const SnackBar(content: Text("Please Try again")));
    }
  }

  savePref(
    int value,
    String name,
    String email,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setInt("value", value);
    preferences.setString("name", name);
    preferences.setString("email", email);
    //preferences.setString("id", id.toString());
  }
}