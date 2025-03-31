import 'package:flutter/material.dart';
import '../widgets/text_field1.dart';


class LoginScreen extends StatelessWidget {
 final TextEditingController _usernameController = TextEditingController();
 final TextEditingController _passwordController = TextEditingController();


 LoginScreen({super.key});


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: const Text('Login')),
     body: Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
           Text('Welcome to Virtual Debate Coach', style: Theme.of(context).textTheme.titleLarge),
           const SizedBox(height: 20),
           textField1(hintText: 'Username', controller: _usernameController, obscureText: false,),
           textField1(hintText: 'Password', obscureText: true, controller: _passwordController),
           _loginButton(context),
         ],
       ),
     ),
   );
 }


 Widget _loginButton(BuildContext context) {
   return ElevatedButton(
     onPressed: () {
       //doth
     },
     child: const Text('Login'),
   );
 }
}
