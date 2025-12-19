import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BancolombiaApp extends StatelessWidget {
  final Color appColor;
  const BancolombiaApp({super.key, required this.appColor});

  @override
  Widget build(BuildContext context) {
    // Define el tema oscuro principal para la aplicación
    return MaterialApp(
      title: 'Bancolombia Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: appColor,
        scaffoldBackgroundColor: appColor,
        fontFamily:
            'Roboto', // Puedes usar una fuente personalizada si la tienes
      ),
      home: const TransactionsScreen(),
    );
  }
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // El índice 1 corresponde a "Transacciones" que está seleccionado por defecto
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Asegura que la barra de estado del sistema tenga iconos claros
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // Acción para el botón de volver
          },
        ),
        // El logo del banco en el centro de la AppBar
        title: Image.asset(
          'assets/images/logo-blanco.png', // Asegúrate de tener este logo en tu carpeta assets
          height: 50,
          errorBuilder: (context, error, stackTrace) {
            // Placeholder en caso de que el logo no cargue
            return const Icon(
              Icons.horizontal_rule,
              color: Colors.white,
              size: 50,
            );
          },
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Contenido principal de la pantalla
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Transacciones',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pagar tarjetas y créditos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                // Tarjetas de opciones
                _buildOptionCard(
                  icon: Icons.credit_card,
                  title: 'Pagar tus tarjetas',
                ),
                const SizedBox(height: 12),
                _buildOptionCard(
                  icon: Icons.payments_outlined,
                  title: 'Pagar otras tarjetas',
                  subtitle: 'Tarjetas de Crédito Bancolombia',
                ),
                const SizedBox(height: 12),
                _buildOptionCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pagar créditos',
                ),
              ],
            ),
          ),
          // Gráfico colorido en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/colorful_wave.png', // Asegúrate de tener esta imagen en tu carpeta assets
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Placeholder en caso de que la imagen no cargue
                return Container(height: 50, color: Colors.transparent);
              },
            ),
          ),
        ],
      ),
      // Barra de navegación inferior personalizada
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  /// Widget para construir cada tarjeta de opción
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(color: Colors.grey))
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: () {
          // Acción al tocar la tarjeta
        },
      ),
    );
  }

  /// Widget para construir la barra de navegación inferior personalizada
  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 70,
      color: const Color(0xFF1A1A1A), // Fondo de la barra de navegación
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home_outlined, label: 'Inicio', index: 0),
          _buildNavItem(
            icon: Icons.swap_horiz,
            label: 'Transacciones',
            index: 1,
          ),
          _buildNavItem(icon: Icons.apps_outlined, label: 'Explorar', index: 2),
          _buildNavItem(
            icon: Icons.description_outlined,
            label: 'Trámites',
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.settings_outlined,
            label: 'Ajustes',
            index: 4,
          ),
        ],
      ),
    );
  }

  /// Widget para construir cada elemento de la barra de navegación
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD100) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,

                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
