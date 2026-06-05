import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool cargando = false;
  bool verPassword = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _mostrarSnack("Por favor completa todos los campos");
      return;
    }
    setState(() => cargando = true);

    final response = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => cargando = false);

    if (response["success"]) {
      final nombreUsuario = response["data"]["usuario"] ?? "Usuario";
      final token = response["data"]["access_token"] ?? "";
      final email = emailController.text.trim();

      // ── GUARDAR sesión en SharedPreferences ──────────────
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('nombre_usuario', nombreUsuario);
      await prefs.setString('email', email);
      // ─────────────────────────────────────────────────────

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => HomeScreen(
                nombreUsuario: nombreUsuario,
                token: token,
                email: email,
              ),
        ),
      );
    } else {
      _mostrarSnack(response["message"] ?? "Error al iniciar sesión");
    }
  }

  void _mostrarSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E2723),
      body: Column(
        children: [
          // ── Hero superior ──────────────────────────────────
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFF3E2723),
              width: double.infinity,
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.coffee_rounded,
                        size: 42,
                        color: Color(0xFFEFEBE9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Finca Cafetera",
                      style: TextStyle(
                        color: Color(0xFFEFEBE9),
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Sistema de monitoreo cafetero",
                      style: TextStyle(color: Color(0xFFBCAAA4), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Formulario ─────────────────────────────────────
          Expanded(
            flex: 3,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Ingresa tus credenciales para continuar",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "Correo electrónico",
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              color: Color(0xFF8D6E63),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: !verPassword,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFF8D6E63),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                verPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF8D6E63),
                              ),
                              onPressed:
                                  () => setState(
                                    () => verPassword = !verPassword,
                                  ),
                            ),
                          ),
                          onSubmitted: (_) => login(),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: cargando ? null : login,
                            child:
                                cargando
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFEFEBE9),
                                      ),
                                    )
                                    : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Ingresar"),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
