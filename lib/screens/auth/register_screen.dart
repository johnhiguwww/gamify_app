import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/form_bits.dart';

// #$ RegisterScreen — nome, apelido (usado como avatar/nome de exibição),
// email e senha. Ao concluir, cria o usuário no Supabase Auth + a linha em
// `profiles`, e volta pro Login (o AuthGate assume dali pra frente).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signUp(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada! Verifique seu email se a confirmação estiver ativada.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = 'Não foi possível criar a conta. Verifique os dados e tente de novo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Criar conta', style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Nome',
                  hint: 'Como podemos te chamar oficialmente (ex: João)',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Digite seu nome' : null,
                ),
                AppTextField(
                  controller: _nicknameController,
                  label: 'Apelido',
                  hint: 'Como vai aparecer no app (ex: João33_fofo/ Pode ser qualquer apelido)',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Digite um apelido' : null,
                ),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'seuemail@exemplo.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Digite um email válido' : null,
                ),
                AppTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Mínimo de 6 caracteres',
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null,
                ),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12.5)),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.black),
                          )
                        : const Text('Criar conta', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
