import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _apiService = ApiService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _apiService.login(_emailController.text, _passwordController.text);
        if (mounted) {
          Provider.of<AuthProvider>(context, listen: false).setAuthenticated(true);
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } else {
        await _apiService.register(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );
        setState(() {
          _isLogin = true;
          _errorMessage = '登録完了。ログインしてください。';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade50,
              Colors.white,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade500, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Talllk',
                      style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                        color: Colors.orange.shade600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '会話の準備をサポート',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => setState(() => _isLogin = true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isLogin ? Colors.orange : Colors.grey.shade200,
                                      foregroundColor: _isLogin ? Colors.white : Colors.grey.shade600,
                                      elevation: _isLogin ? 4 : 0,
                                    ),
                                    child: const Text('ログイン'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => setState(() => _isLogin = false),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: !_isLogin ? Colors.orange : Colors.grey.shade200,
                                      foregroundColor: !_isLogin ? Colors.white : Colors.grey.shade600,
                                      elevation: !_isLogin ? 4 : 0,
                                    ),
                                    child: const Text('新規登録'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            if (_errorMessage != null) const SizedBox(height: 16),
                            if (!_isLogin)
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: '名前',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                    value?.isEmpty ?? true ? '名前を入力してください' : null,
                              ),
                            if (!_isLogin) const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'メールアドレス',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'メールアドレスを入力してください' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'パスワード',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'パスワードを入力してください' : null,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(_isLogin ? 'ログイン' : '登録する'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '面接、デート、会議などの準備に最適',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
