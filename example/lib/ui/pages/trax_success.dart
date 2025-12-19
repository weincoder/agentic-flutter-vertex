import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransferSuccessScreen extends StatefulWidget {
  final String amount;
  final String nickname;
  final String accountType;
  // Constructor para recibir los datos de la transferencia
  final Color appColor;
  const TransferSuccessScreen({
    super.key,
    required this.amount,
    required this.nickname,
    required this.accountType,
    required this.appColor,
  });

  @override
  State<TransferSuccessScreen> createState() => _TransferSuccessScreenState();
}

class _TransferSuccessScreenState extends State<TransferSuccessScreen> {
  int _selectedIndex = 1; // Índice para 'Transacciones'

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.appColor,
      appBar: AppBar(
        backgroundColor: widget.appColor,
        elevation: 0,
        // Asumo que el logo es una imagen, aquí se usa un placeholder
        title: Image.asset(
          'assets/images/logo-blanco.png', // Reemplaza con la ruta a tu logo
          width: 30,
          // Si tu logo no se ve bien, puedes necesitar un widget `Image.asset`
          // o `SvgPicture.asset` si es un SVG.
          errorBuilder:
              (context, error, stackTrace) => const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 30,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Row(
              children: [
                Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(Icons.logout, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFF34C759), // Verde éxito
              child: Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Transferencia exitosa!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Comprobante No. 0000091900',
              style: TextStyle(color: Colors.grey),
            ),
            const Text(
              '19 jul 2025 - 07:26 p. m.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // --- Tarjetas de Información ---
            InfoCard(
              title: 'Datos de la transferencia',
              child: Column(
                children: [
                  _buildDetailRow(
                    'Valor de la transferencia',
                    '${widget.amount}',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Costo de la transferencia', '\$ 0,00'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Producto destino',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nickname,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ahorros / Bancolombia A la mano',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '342 - 982856 - 16',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Producto origen',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.accountType}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ahorros',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2C2C2E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[500],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transacciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_sharp),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Trámites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Widget reutilizable para las tarjetas de información
class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const InfoCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
            ],
          ),
          const Divider(color: Colors.grey, height: 24),
          child,
        ],
      ),
    );
  }
}
