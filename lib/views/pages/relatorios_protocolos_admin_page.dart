import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar_atendente.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import 'relatorio_admin_page.dart';
import 'protocolos_admin_page.dart';

class RelatoriosProtocolosAdminPage extends StatefulWidget {
  const RelatoriosProtocolosAdminPage({super.key});

  @override
  State<RelatoriosProtocolosAdminPage> createState() => _RelatoriosProtocolosAdminPageState();
}

class _RelatoriosProtocolosAdminPageState extends State<RelatoriosProtocolosAdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = AuthService().currentUser;
      if (user != null) {
        final userData = await UserService().getUser(user.uid);
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null || !_userData!.isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text('Acesso negado. Apenas administradores podem acessar esta página.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: AppLogo()),
            ),

            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  text: 'Relatórios',
                ),
                Tab(
                  text: 'Protocolos',
                ),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  RelatorioAdminPage(),
                  ProtocolosAdminPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBarAtendente(selectedIndex: 3),
    );
  }
}