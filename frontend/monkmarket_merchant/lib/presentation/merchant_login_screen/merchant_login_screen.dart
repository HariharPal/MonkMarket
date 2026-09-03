import '../../core/app_export.dart';
import '../../features/auth/viewmodels/login_viewmodel.dart';
import './widgets/demo_credentials_widget.dart';
import './widgets/login_brand_header_widget.dart';
import './widgets/login_form_widget.dart';

class MerchantLoginScreen extends ConsumerStatefulWidget {
  const MerchantLoginScreen({super.key});

  @override
  ConsumerState<MerchantLoginScreen> createState() =>
      _MerchantLoginScreenState();
}

class _MerchantLoginScreenState extends ConsumerState<MerchantLoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    ref.listenManual<LoginState>(loginProvider, (previous, next) {
      if (!mounted) return;

      if (next is LoginSuccess) {
        context.go(AppRoutes.dashboardScreen);
      }
    });

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    ref.listen<LoginState>(loginProvider, (prev, next) {
      if (next is LoginSuccess) {
        context.go(AppRoutes.dashboardScreen);
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: isTablet
                ? _buildTabletLayout(context, theme)
                : _buildPhoneLayout(context, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const LoginBrandHeaderWidget(),
          const SizedBox(height: 40),
          const LoginFormWidget(),
          const SizedBox(height: 32),
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: AppTheme.elevatedCardDecoration(context),
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginBrandHeaderWidget(),
                const SizedBox(height: 36),
                const LoginFormWidget(),
                const SizedBox(height: 24),
                const DemoCredentialsWidget(),
                const SizedBox(height: 24),
                _buildFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Text(
      '© 2026 MonkMarket · Merchant Portal v1.0',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        color: theme.colorScheme.outline,
      ),
      textAlign: TextAlign.center,
    );
  }
}
