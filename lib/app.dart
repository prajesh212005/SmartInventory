import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/product_management_screen.dart';
import 'screens/stock_update_screen.dart';
import 'screens/stock_history_screen.dart';
import 'screens/search_filter_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'utils/app_colors.dart';

class SmartInventoryApp extends StatelessWidget {
  const SmartInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Inventory & Stock Replenishment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          centerTitle: true,
          elevation: 0,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: const TextStyle(color: AppColors.textPrimary),
          bodyMedium: const TextStyle(color: AppColors.textSecondary),
        ),
        cardColor: AppColors.surface,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface.withOpacity(0.8),
          indicatorColor: AppColors.primary.withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 28);
            }
            return const IconThemeData(color: AppColors.textSecondary, size: 24);
          }),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: AppColors.surface.withOpacity(0.5),
          selectedIconTheme: const IconThemeData(color: AppColors.primary, size: 30),
          unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary, size: 26),
          selectedLabelTextStyle: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700),
          unselectedLabelTextStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          useIndicator: true,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    
    if (authService.isAuthenticated) {
      return const MainNavigator();
    } else {
      return const LoginScreen();
    }
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductManagementScreen(),
    const StockUpdateScreen(),
    const StockHistoryScreen(),
    const SearchFilterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2_rounded),
                  label: Text('Products'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.sync_alt_outlined),
                  selectedIcon: Icon(Icons.sync_alt_rounded),
                  label: Text('Update'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history_rounded),
                  label: Text('History'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search_rounded),
                  label: Text('Search'),
                ),
              ],
            ),
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync_alt_outlined),
            selectedIcon: Icon(Icons.sync_alt_rounded),
            label: 'Update',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}
