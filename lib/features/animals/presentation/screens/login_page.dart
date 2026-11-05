import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../data/services/auth_service.dart';
import '../../../../validators/auth_validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authService});
  final AuthService authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegisterMode = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (_isRegisterMode) {
        await widget.authService.register(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await widget.authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      debugPrint('[Auth] FirebaseAuthException: ${error.code}');
      if (!mounted) return;
      setState(() => _errorMessage = _mapFirebaseError(error));
    } catch (error) {
      debugPrint('[Auth] Error inesperado: $error');
      if (!mounted) return;
      setState(
        () => _errorMessage = 'No fue posible completar la autenticación',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'El correo no tiene un formato válido';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'weak-password':
        return 'La contraseña no cumple la política requerida';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada';
      case 'operation-not-allowed':
        return 'El acceso con correo y contraseña no está habilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente más tarde';
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
        return 'Las credenciales no coinciden';
      case 'network-request-failed':
        return 'Revisa tu conexión a internet';
      default:
        return 'No fue posible completar la autenticación';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movies')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isRegisterMode ? 'Crear cuenta' : 'Iniciar sesión',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      autofocus: true,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        border: OutlineInputBorder(),
                      ),
                      validator: AuthValidators.validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                      ),
                      validator: AuthValidators.validatePassword,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) _submit();
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isRegisterMode ? 'Registrarme' : 'Ingresar'),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                              _isRegisterMode = !_isRegisterMode;
                              _errorMessage = null;
                            }),
                      child: Text(
                        _isRegisterMode
                            ? 'Ya tengo cuenta'
                            : 'Crear una cuenta',
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
