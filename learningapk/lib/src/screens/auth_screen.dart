import 'package:flutter/material.dart';

import '../app_controller.dart';
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: LaravelMark(),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _register ? 'Anza safari yako' : 'Karibu tena 👋',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900, color: ink),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _register
                          ? 'Jiunge na community ya kujifunza Laravel Tanzania, ufanye quiz na uzungumze na admin.'
                          : 'Ingia kufanya quiz, kuhifadhi maendeleo na kuchat na admin.',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_register) ...[
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Jina kamili',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            value == null || value.trim().length < 2
                            ? 'Andika jina lako.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email au username',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Andika email au username.';
                        }
                        if (_register && !value.contains('@')) {
                          return 'Andika barua pepe sahihi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Nenosiri',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 8
                          ? 'Tumia herufi 8 au zaidi.'
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 22),
                    ListenableBuilder(
                      listenable: widget.controller,
                      builder: (context, _) => FilledButton(
                        onPressed: widget.controller.busy ? null : _submit,
                        child: widget.controller.busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_register ? 'Tengeneza akaunti' : 'Ingia'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {
                        widget.controller.clearError();
                        setState(() => _register = !_register);
                      },
                      child: Text(
                        _register
                            ? 'Una akaunti tayari? Ingia'
                            : 'Huna akaunti? Jisajili hapa',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Laravel • Kiswahili • Vitendo',
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
    );
  }
}
