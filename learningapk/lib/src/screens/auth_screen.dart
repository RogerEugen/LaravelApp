import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../localization.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.controller,
    this.communityMessage = true,
  });
  final AppController controller;
  final bool communityMessage;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final success = _register
        ? await widget.controller.register(
            _name.text,
            _email.text,
            _password.text,
          )
        : await widget.controller.login(_email.text, _password.text);
    if (success && mounted) {
      Navigator.pop(context, true);
      return;
    }
    if (!success && mounted) showMessage(context, widget.controller.error!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF7F6), Color(0xFFF4F5FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: LaravelMark(),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _register
                                ? context.tr('start_journey')
                                : context.tr('welcome_back'),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: ink,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _register
                                ? context.tr('register_subtitle')
                                : context.tr('login_subtitle'),
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 26),
                          if (_register) ...[
                            TextFormField(
                              controller: _name,
                              decoration: InputDecoration(
                                labelText: context.tr('full_name'),
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().length < 2
                                  ? 'Enter your full name.'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                          ],
                          TextFormField(
                            controller: _email,
                            decoration: InputDecoration(
                              labelText: context.tr('email_or_username'),
                              prefixIcon: const Icon(Icons.alternate_email),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter email or username.'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: context.tr('password'),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.length < 8
                                ? 'Use at least 8 characters.'
                                : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 22),
                          ListenableBuilder(
                            listenable: widget.controller,
                            builder: (context, _) => FilledButton(
                              onPressed: widget.controller.busy
                                  ? null
                                  : _submit,
                              child: widget.controller.busy
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _register
                                          ? context.tr('create_account')
                                          : context.tr('sign_in'),
                                    ),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _register = !_register),
                            child: Text(
                              _register
                                  ? context.tr('have_account')
                                  : context.tr('no_account'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Developed by Rogers Eugen',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF98A2B3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
