import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../user/data/datasources/region_remote_datasource.dart';
import '../../../user/domain/entities/region.dart';
import '../providers/auth_provider.dart';
import '../../../../main_screen.dart';

/// Screen Login & Register dengan desain Glassmorphism.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _obscurePassword = true;

  // Login
  late final TextEditingController _emailCtrl;
  final _passwordCtrl = TextEditingController(text: 'password123');

  // Register
  final _usernameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();

  // Region
  final RegionService _regionService = RegionService();
  List<Region> _provinces = [];
  List<Region> _cities = [];
  List<Region> _districts = [];
  List<Region> _villages = [];
  Region? _selectedProvince;
  Region? _selectedCity;
  Region? _selectedDistrict;
  Region? _selectedVillage;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: AppConfig.mail);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
    _loadProvinces();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _streetCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    try {
      _provinces = await _regionService.getProvinces();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _onProvinceChanged(Region? province) async {
    setState(() {
      _selectedProvince = province;
      _selectedCity = null;
      _selectedDistrict = null;
      _selectedVillage = null;
      _cities = [];
      _districts = [];
      _villages = [];
    });
    if (province != null) {
      _cities = await _regionService.getRegencies(province.id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _onCityChanged(Region? city) async {
    setState(() {
      _selectedCity = city;
      _selectedDistrict = null;
      _selectedVillage = null;
      _districts = [];
      _villages = [];
    });
    if (city != null) {
      _districts = await _regionService.getDistricts(city.id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _onDistrictChanged(Region? district) async {
    setState(() {
      _selectedDistrict = district;
      _selectedVillage = null;
      _villages = [];
    });
    if (district != null) {
      _villages = await _regionService.getVillages(district.id);
      if (mounted) setState(() {});
    }
  }

  void _toggleMode() {
    _animCtrl.reset();
    setState(() => _isLogin = !_isLogin);
    _animCtrl.forward();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      _usernameCtrl.text.trim(),
      _regEmailCtrl.text.trim(),
      _regPasswordCtrl.text,
      _fullNameCtrl.text.trim(),
      province: _selectedProvince?.name,
      city: _selectedCity?.name,
      district: _selectedDistrict?.name,
      village: _selectedVillage?.name,
      street: _streetCtrl.text.trim(),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppColors.success,
        ),
      );
      _toggleMode();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registrasi gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1FA89A), Color(0xFF2AC6B6), Color(0xFF5DDCCE)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.handshake_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isLogin ? 'Selamat Datang!' : 'Buat Akun Baru',
                          style: AppTextStyles.h1,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? 'Masuk ke akun Meetup kamu'
                              : 'Daftar untuk mulai bertransaksi',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 28),

                        if (_isLogin) ...[
                          AppTextField(
                            controller: _emailCtrl,
                            hintText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                v!.isEmpty ? 'Email wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordCtrl,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Password wajib diisi' : null,
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            label: 'Masuk',
                            onPressed: _handleLogin,
                            isLoading: auth.isLoading,
                          ),
                        ] else ...[
                          AppTextField(
                            controller: _fullNameCtrl,
                            hintText: 'Nama Lengkap',
                            prefixIcon: Icons.person_outline,
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _usernameCtrl,
                            hintText: 'Username',
                            prefixIcon: Icons.alternate_email,
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _regEmailCtrl,
                            hintText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _regPasswordCtrl,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            validator: (v) =>
                                v!.length < 6 ? 'Min 6 karakter' : null,
                          ),
                          const SizedBox(height: 20),

                          // Region pickers
                          _buildRegionDropdown(
                            'Provinsi',
                            _provinces,
                            _selectedProvince,
                            _onProvinceChanged,
                          ),
                          const SizedBox(height: 12),
                          _buildRegionDropdown(
                            'Kota/Kabupaten',
                            _cities,
                            _selectedCity,
                            _onCityChanged,
                          ),
                          const SizedBox(height: 12),
                          _buildRegionDropdown(
                            'Kecamatan',
                            _districts,
                            _selectedDistrict,
                            _onDistrictChanged,
                          ),
                          const SizedBox(height: 12),
                          _buildRegionDropdown(
                            'Kelurahan/Desa',
                            _villages,
                            _selectedVillage,
                            (v) => setState(() => _selectedVillage = v),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _streetCtrl,
                            hintText: 'Jalan / Alamat Detail',
                            prefixIcon: Icons.home_outlined,
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            label: 'Daftar',
                            onPressed: _handleRegister,
                            isLoading: auth.isLoading,
                          ),
                        ],

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? 'Belum punya akun?'
                                  : 'Sudah punya akun?',
                              style: AppTextStyles.bodyMedium,
                            ),
                            TextButton(
                              onPressed: _toggleMode,
                              child: Text(
                                _isLogin ? 'Daftar' : 'Masuk',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildRegionDropdown(
    String label,
    List<Region> items,
    Region? selected,
    ValueChanged<Region?> onChanged,
  ) {
    return DropdownButtonFormField<Region>(
      // ignore: deprecated_member_use
      value: selected,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (r) => DropdownMenuItem(
              value: r,
              child: Text(r.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
