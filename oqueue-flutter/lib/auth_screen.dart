
import 'package:flutter/material.dart';
import 'package:oqueue/api.dart';

// Create a Form widget.
class AuthScreen extends StatefulWidget {
  final void Function(Api api)? onAuth;
  final AuthApi authApi;

  const AuthScreen({required this.authApi, this.onAuth});

  void callOnAuth(Api api) {
    if(onAuth != null) {
      onAuth!(api);
    }
  }

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login or create account'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Sign In"),
              Tab(text: "Sign Up"),
            ],
          ),
        ),
        body: TabBarView(children: [
          SignInForm(
            authApi: this.widget.authApi,
            onAuth: this.widget.onAuth
          ),
          SignUpForm(
            authApi: this.widget.authApi,
            onAuth: this.widget.onAuth
          )
        ])
    ));
  }
}

// Create a Form widget.
class SignInForm extends StatefulWidget {
  final void Function(Api api)? onAuth;
  final AuthApi authApi;

  const SignInForm({required this.authApi, this.onAuth});

  void callOnAuth(Api api) {
    if(onAuth != null) {
      onAuth!(api);
    }
  }

  @override
  SignInFormState createState() => SignInFormState();
}

class SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: inputDecorationBase('login (email)'),
            controller: loginController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter login (email)';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: inputDecorationBase('password'),
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    Api api = await this.widget.authApi.signin(
                        loginController.text,
                        passwordController.text
                    );
                    widget.callOnAuth(api);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Sign In'),
            ),
          ),
        ],
      ),
    );
  }
}


// Create a Form widget.
class SignUpForm extends StatefulWidget {
  final void Function(Api api)? onAuth;
  final AuthApi authApi;

  const SignUpForm({required this.authApi, this.onAuth});

  void callOnAuth(Api api) {
    if(onAuth != null) {
      onAuth!(api);
    }
  }

  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: emailController,
            decoration: inputDecorationBase('email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: nameController,
            decoration: inputDecorationBase('name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: passwordController,
            decoration: inputDecorationBase('password'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    Api api = await this.widget.authApi.signup(
                        emailController.text,
                        nameController.text,
                        passwordController.text
                    );
                    widget.callOnAuth(api);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration inputDecorationBase(String? labelText) {
  return InputDecoration(
      border: const UnderlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
      labelText: labelText,
  );
}
