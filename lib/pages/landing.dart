import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String? _userFirstName;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _getUserFirstName(user.uid);
    }
  }

  Future<void> _getUserFirstName(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        setState(() {
          _userFirstName = doc['first_name'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _userFirstName = null;
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => LoginDialog(
        onLoginSuccess: _checkUser,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 80,
            ),
            const SizedBox(width: 10),
            const Text('StoreLink'),
          ],
        ),
        actions: [
          if (_userFirstName == null)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: _showLoginDialog,
            )
          else
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text('Hi, $_userFirstName!'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                ),
              ],
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hi there, would you like to...', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        _showLoginDialog();
                      } else {
                        Navigator.pushNamed(context, '/find');
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Find Storage', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        _showLoginDialog();
                      } else {
                        Navigator.pushNamed(context, '/lend');
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Lend Storage', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class LoginDialog extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final VoidCallback onLoginSuccess;

  LoginDialog({super.key, required this.onLoginSuccess});

  Future<void> _login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      onLoginSuccess();
      Navigator.of(context).pop();
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _login(context),
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}