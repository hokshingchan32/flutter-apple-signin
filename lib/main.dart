import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _credential = 'No credential';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_credential),
                const Spacer(),
                Center(
                  child: SignInWithAppleButton(
                    onPressed: () => signIn(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);

      Map<String, String> data = {};

      data['authorizationCode'] = credential.authorizationCode;

      // email, familyName, givenNameは、
      // このアプリが初めてAppleを使ってログインした時のみ、返却されます。
      // 初回以降は返却されない。
      data['email'] = credential.email ?? '';
      data['familyName'] = credential.familyName ?? '';
      data['givenName'] = credential.givenName ?? '';

      data['identityToken'] = credential.identityToken ?? '';
      data['userIdentifier'] = credential.userIdentifier ?? '';

      setState(() {
        final buffer = StringBuffer('');
        buffer.write('{\n');
        for (var element in data.entries) {
          buffer.write('    ${element.key}: ${element.value}\n');
        }
        buffer.write('}\n');
        _credential = buffer.toString();
      });
      print(data);
    } on SignInWithAppleAuthorizationException catch (e) {
      print(e.code.name + ' ' + e.message);
    }
  }
}
