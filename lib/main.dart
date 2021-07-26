import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_ui/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/login': (context) => Login(),
        },
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _key = GlobalKey<FormState>();
  var _pwd = false;
  final _userName = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  var signup = false;
  var signin = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void loginWithEmail({required String email, required String password}) async {
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('LoggedIn with Email !!!')));
        Navigator.of(context).pushNamed('/login');
      }).catchError((onError) {
        print(onError);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void signupWithEmail(
      {required String email, required String password}) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('LoggedIn with Email !!!')));
        Navigator.of(context).pushNamed('/login');
      }).catchError((onError) {
        print(onError);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void login({required String mobile, required BuildContext context}) async {
    mobile = '+91' + mobile;
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: mobile,
          timeout: Duration(seconds: 30),
          verificationCompleted: (phoneAuthCredential) async {
            await _auth.signInWithCredential(phoneAuthCredential).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('LoggedIn with phone Auth !!!')));
              Navigator.of(context).pushNamed('/login');
            }).catchError((onError) {
              print(onError);
            });
          },
          verificationFailed: (e) {
            print(e.message);
          },
          codeSent: (verificationId, [int? resend_id]) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Enter OTP'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _otp,
                    ),
                  ],
                ),
                actions: [
                  OutlinedButton(
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.blue, backgroundColor: Colors.white),
                    ),
                    onPressed: () {
                      FirebaseAuth auth = FirebaseAuth.instance;

                      var smsCode = _otp.text.trim();

                      var _credential = PhoneAuthProvider.credential(
                          verificationId: verificationId, smsCode: smsCode);
                      auth
                          .signInWithCredential(_credential)
                          .then((result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logged In via OTP')));
                        Navigator.of(context).pushNamed('/login');
                      }).catchError((e) {
                        print(e);
                      });
                    },
                  )
                ],
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print(verificationId);
          });
    } catch (e) {
      print(e.toString());
    }
  }

  void loginWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
        await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    _auth.signInWithCredential(credential).then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Signed in by google')));
      Navigator.of(context).pushNamed('/login');
    });
  }

  void loginWithFacebook() async {
    var login = FacebookLogin();
    var loginResult = await login.logInWithReadPermissions(['email']);
    switch (loginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login by Facebook done!!')));
        Navigator.of(context).pushNamed('/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            Form(
              key: _key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person_outline,
                      size: MediaQuery.of(context).size.width / 4,
                    ),
                  ),
                  if (signin || signup)
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _userName,
                            decoration: InputDecoration(
                              labelText: 'Email ID / Phone No.',
                              contentPadding: EdgeInsets.all(10),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email ID / Phone No. is required';
                              }
                            },
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          TextFormField(
                            controller: _password,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              contentPadding: EdgeInsets.all(10),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                            },
                            enabled: _pwd,
                          ),
                        ],
                      ),
                    ),
                  if (!signup)
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            elevation: MaterialStateProperty.all(5)),
                        onPressed: () {
                          if (signin) {
                            if (_pwd) {
                              var email = _userName.text;
                              var password = _password.text;
                              loginWithEmail(email: email, password: password);
                            } else {
                              var mobile = _userName.text;
                              login(mobile: mobile, context: context);
                            }
                          } else {
                            setState(() {
                              signin = true;
                              signup = false;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'SIGN IN',
                            style: TextStyle(
                                backgroundColor: Colors.blue,
                                color: Colors.white,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  if (!signup || signin)
                    Padding(
                      child: Divider(),
                      padding: EdgeInsets.all(10),
                    ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: OutlinedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          elevation: MaterialStateProperty.all(5)),
                      onPressed: () {
                        if (signup) {
                          var email = _userName.text;
                          var password = _password.text;
                          signupWithEmail(email: email, password: password);
                        } else {
                          setState(() {
                            signup = true;
                            signin = false;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                              backgroundColor: Colors.blue,
                              color: Colors.white,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  if (signup)
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: OutlinedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                  elevation: MaterialStateProperty.all(5)),
                              onPressed: () {
                                loginWithGoogle();
                              },
                              child: Container(
                                padding: EdgeInsets.all(15),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'GOOGLE',
                                  style: TextStyle(
                                      backgroundColor: Colors.blue,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: OutlinedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                  elevation: MaterialStateProperty.all(5)),
                              onPressed: () {
                                loginWithFacebook();
                              },
                              child: Container(
                                padding: EdgeInsets.all(15),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'FACEBOOK',
                                  style: TextStyle(
                                      backgroundColor: Colors.blue,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _password.dispose();
    _userName.dispose();
    _otp.dispose();
    super.dispose();
  }

  void check() {
    if (_userName.text!.contains('@')) {
      _pwd = true;
    } else {
      _pwd = false;
    }
  }

  @override
  void initState() {
    _userName.addListener(check);
    super.initState();
  }
}
