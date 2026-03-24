import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Controllers connexion
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Controllers inscription
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();

  bool _loginPassVisible = false;
  bool _regPassVisible = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mon compte',
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: const Color(0xFF1A3C34),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1A3C34),
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
          tabs: const [
            Tab(text: 'Se connecter'),
            Tab(text: "S'inscrire"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildLoginTab(),
          _buildRegisterTab(),
        ],
      ),
    );
  }

  // ── Onglet Connexion ──────────────────────────────────────────────────────
  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue de retour',
            style: GoogleFonts.montserrat(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Connectez-vous pour accéder à vos réservations.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _label('Adresse e-mail'),
          const SizedBox(height: 8),
          _textField(
            controller: _loginEmailCtrl,
            hint: 'votre@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _label('Mot de passe'),
          const SizedBox(height: 8),
          _textField(
            controller: _loginPassCtrl,
            hint: '••••••••',
            isPassword: true,
            isVisible: _loginPassVisible,
            onToggleVisibility: () =>
                setState(() => _loginPassVisible = !_loginPassVisible),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Mot de passe oublié ?',
                style: GoogleFonts.inter(
                    color: const Color(0xFF1A7EFF), fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _primaryButton(
            label: 'Se connecter',
            onPressed: () {
              // TODO : Brancher sur l'API Auth
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ── Onglet Inscription ────────────────────────────────────────────────────
  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Créer un compte',
            style: GoogleFonts.montserrat(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Rejoignez la communauté Discover Cameroon.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _label('Nom complet'),
          const SizedBox(height: 8),
          _textField(
            controller: _regNameCtrl,
            hint: 'Jean-Paul Mbarga',
          ),
          const SizedBox(height: 16),
          _label('Adresse e-mail'),
          const SizedBox(height: 8),
          _textField(
            controller: _regEmailCtrl,
            hint: 'votre@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _label('Mot de passe'),
          const SizedBox(height: 8),
          _textField(
            controller: _regPassCtrl,
            hint: 'Minimum 8 caractères',
            isPassword: true,
            isVisible: _regPassVisible,
            onToggleVisibility: () =>
                setState(() => _regPassVisible = !_regPassVisible),
          ),
          const SizedBox(height: 12),
          // Conditions
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "En créant un compte, vous acceptez nos Conditions générales d'utilisation et notre Politique de confidentialité.",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500], height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          _primaryButton(
            label: 'Créer mon compte',
            onPressed: () {
              // TODO : Brancher sur l'API Auth
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ── Widgets partagés ──────────────────────────────────────────────────────

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !isVisible,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A3C34), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  isVisible ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: Colors.grey[500],
                ),
              )
            : null,
      ),
    );
  }

  Widget _primaryButton(
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A3C34),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou',
              style:
                  GoogleFonts.inter(fontSize: 13, color: Colors.grey[500])),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _socialButton(
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: Colors.black87),
        label: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
