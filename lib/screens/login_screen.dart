import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/screens/splash_screen.dart';
import 'package:quiz_app/theme/app_background.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authRepo = ref.read(authRepositoryProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimaryFixedVariant,
          automaticallyImplyLeading: false,
          title: Text(
            "Login",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).viewInsets.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: 30,
                        bottom: 20,
                        left: 20,
                        right: 20,
                      ),
                      width: 200,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            cursorColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              decorationColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              color: Theme.of(context).colorScheme.onPrimary,
                              decorationThickness: 0,
                            ),
                            controller: _emailController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              labelText: "Email",
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            validator: (value) =>
                                value == null || !value.contains("@")
                                ? "Enter valid email"
                                : null,
                          ),
                          SizedBox(height: 12),

                          TextFormField(
                            controller: _passwordController,
                            cursorColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            style: TextStyle(
                              decorationColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              color: Theme.of(context).colorScheme.onPrimary,
                              decorationThickness: 0,
                            ),
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  width: 2,
                                ),
                              ),
                              labelText: "Password",
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),

                            validator: (value) =>
                                value == null || value.length < 6
                                ? "Password must be at least 6 characters"
                                : null,
                          ),

                          SizedBox(height: 20),
                          _isLoading
                              ? CircularProgressIndicator(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate())
                                      return;
                                    setState(() => _isLoading = true);

                                    try {
                                      await authRepo.signIn(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SplashScreen(),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    } finally {
                                      setState(() => _isLoading = false);
                                    }
                                  },
                                  child: const Text("Login"),
                                ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: const Text("Don't have an account? Sign Up"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
