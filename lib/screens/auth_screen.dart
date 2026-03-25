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
          const SizedBox(height: 20),
          _orDivider(),
          const SizedBox(height: 16),
          _googleButton(),
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
            'Rejoignez la communauté Camer Tour.',
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
          const SizedBox(height: 20),
          _orDivider(),
          const SizedBox(height: 16),
          _googleButton(),
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

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          // TODO : Brancher google_sign_in
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFDADCE0), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Google (G multicolore)
            _GoogleLogo(),
            const SizedBox(width: 12),
            Text(
              'Continuer avec Google',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3C4043),
              ),
            ),
          ],
        ),
      ),
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

// ─── Logo Google en SVG manuel (4 couleurs officielles) ──────────────────────
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w / 2;

    // Cercle blanc de fond
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = Colors.white,
    );

    // "G" composé de 4 arcs colorés — approche simplifiée avec 4 secteurs
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.85);

    void drawArc(Color color, double start, double sweep) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        true,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    // Rouge (haut-droite)
    drawArc(const Color(0xFFEA4335), -0.52, 1.05);
    // Jaune (bas-droite)
    drawArc(const Color(0xFFFBBC04), 0.53, 1.05);
    // Vert (bas-gauche)
    drawArc(const Color(0xFF34A853), 1.58, 1.05);
    // Bleu (haut-gauche)
    drawArc(const Color(0xFF4285F4), 2.63, 1.57);

    // Cercle central blanc pour effet anneau
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.55,
      Paint()..color = Colors.white,
    );

    // Barre horizontale droite du G
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx, cy - r * 0.14, r * 0.85, r * 0.28),
        Radius.circular(r * 0.05),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
