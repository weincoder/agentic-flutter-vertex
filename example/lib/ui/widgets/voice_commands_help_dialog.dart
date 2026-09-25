import 'package:flutter/material.dart';

/// Diálogo de ayuda para comandos de voz
class VoiceCommandsHelpDialog extends StatelessWidget {
  const VoiceCommandsHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assistant, color: colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Comandos de Voz',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCommandSection(
              icon: Icons.palette_outlined,
              color: Colors.purple,
              title: 'Cambiar Color',
              examples: [
                '"Cambia el color"',
                '"Pon el color azul"',
                '"Color morado"',
              ],
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildCommandSection(
              icon: Icons.question_answer_outlined,
              color: Colors.blue,
              title: 'Hacer Preguntas',
              examples: [
                '"¿Qué tiempo hace?"',
                '"Dame un consejo"',
                '"¿Cuándo es la primavera?"',
              ],
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildCommandSection(
              icon: Icons.summarize_outlined,
              color: Colors.orange,
              title: 'Crear Resumen',
              examples: [
                '"Resume mi día"',
                '"Resumen de la semana"',
                '"Qué he escrito hoy"',
              ],
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildCommandSection(
              icon: Icons.delete_outline,
              color: Colors.red,
              title: 'Eliminar Entrada',
              examples: [
                '"Elimina la última entrada"',
                '"Borra la nota de hoy"',
                '"Elimina mi entrada"',
              ],
              theme: theme,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.mic, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Presiona el botón morado y habla claramente',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandSection({
    required IconData icon,
    required Color color,
    required String title,
    required List<String> examples,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...examples.map(
            (example) => Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: Text(
                '• $example',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
