import 'dart:convert';
import 'dart:ui';

import 'package:darkmodetoggle/backend/collection.dart';
import 'package:darkmodetoggle/backend/databasehandler.dart';
import 'package:darkmodetoggle/backend/sticker.dart';
import 'package:darkmodetoggle/backend/usersticker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darkmodetoggle/apis/api.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  late String email, password;
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late ScaffoldMessengerState scaffoldMessenger;
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 13,
                    ),
                    Text(
                      "Stickers for Steps",
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(fontSize: 27, color: Colors.white, letterSpacing: 1)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: 180,
                      child: Text(
                        "------------",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(color: Colors.white54, letterSpacing: 0.6, fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Sign In",
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
                          "",
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
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              controller: _emailController,
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                hintText: "Username",
                                hintStyle: TextStyle(color: Colors.white70, fontSize: 15),
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
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.white70, fontSize: 15),
                              ),
                              onSaved: (val) {
                                email = val!;
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (isLoading) {
                                      return;
                                    }
                                    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                                      scaffoldMessenger
                                          .showSnackBar(const SnackBar(content: Text("Please Fill all fileds")));
                                      return;
                                    }
                                    login(_emailController.text, _passwordController.text);
                                    setState(() {
                                      isLoading = true;
                                    });
                                    //Navigator.pushReplacementNamed(context, "/stickerscreen");
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      "SUBMIT",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                          textStyle:
                                              const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1)),
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
                    const Text(
                      "OR",
                      style: TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "/signup");
                      },
                      child: Text(
                        "Don't have an account?",
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

  login(username, password) async {
    Map data = {'username': username, 'password': password};
    final response = await http.post(Uri.parse(loginurl),
        headers: {"Accept": "application/json", "Content-Type": "application/x-www-form-urlencoded"},
        body: data,
        encoding: Encoding.getByName("utf-8"));
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> resposne = jsonDecode(response.body);
      if (!resposne.containsKey('error')) {
        String token = resposne['token'];
        savePref(1, 1, token, username);
        Navigator.pushReplacementNamed(context, "/home");
        await fetchCollections();
        populateDB();
      } else {
        // print(" ${resposne['message']}");
      }
      //scaffoldMessenger.showSnackBar(SnackBar(content: Text("$resposne yoyo")));
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("Logged in successfully!")));
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Please try again!")));
    }
  }

  savePref(int value, int id, String token, String username) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString("id", id.toString());
    preferences.setString("token", token);
    preferences.setString("username", username);
    preferences.setInt("value", value);
  }

  Future<void> populateDB() async {
    await DatabaseHandler().retrieveCollections();
    await fetchSticker();
    await fetchUserSticker();
  }
}
