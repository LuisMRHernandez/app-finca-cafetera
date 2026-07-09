import 'package:flutter/material.dart';
import '../utils/constants.dart';

// ── Sección con título e ícono ────────────────────────────────
class SeccionTitulo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Color? color;
  const SeccionTitulo(
      {super.key, required this.icono, required this.titulo, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.verde;
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icono, size: 16, color: c),
      ),
      const SizedBox(width: 10),
      Text(titulo,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.texto)),
    ]);
  }
}

// ── Card contenedor estándar ──────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const AppCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.fondoCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borde),
        ),
        child: child,
      );
}

// ── Fila de información con ícono ─────────────────────────────
// multilinea: true  → valor debajo del label, sin límite de caracteres
// multilinea: false → valor a la derecha en la misma línea (default)
class InfoRow extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color colorFondo;
  final String label;
  final String valor;
  final bool isLast;
  final bool multilinea;

  const InfoRow({
    super.key,
    required this.icono,
    required this.colorIcono,
    required this.colorFondo,
    required this.label,
    required this.valor,
    this.isLast = false,
    this.multilinea = false,
  });

  @override
  Widget build(BuildContext context) {
    final icWidget = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: colorFondo, borderRadius: BorderRadius.circular(10)),
      child: Icon(icono, color: colorIcono, size: 17),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: !isLast
            ? const Border(bottom: BorderSide(color: Color(0xFFEEE8E4)))
            : null,
      ),
      child: multilinea
          // Valor largo: ícono + label encima, texto completo debajo
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              icWidget,
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textoSuave)),
                  const SizedBox(height: 4),
                  Text(valor,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.texto),
                      softWrap: true),
                ],
              )),
            ])
          // Valor corto: label izquierda, valor derecha
          : Row(children: [
              icWidget,
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textoSuave)),
              const Spacer(),
              Flexible(
                  child: Text(valor,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.texto),
                      overflow: TextOverflow.ellipsis)),
            ]),
    );
  }
}

// ── Badge de métrica (Brix / pH / Temp) ──────────────────────
class MetricaBadge extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;
  const MetricaBadge(
      {super.key,
      required this.label,
      required this.valor,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Text(valor,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
          ]),
        ),
      );
}

// ── Estado vacío genérico ─────────────────────────────────────
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback? onReintentar;
  const EstadoVacio(
      {super.key,
      required this.icono,
      required this.titulo,
      required this.subtitulo,
      this.onReintentar});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: AppColors.verde.withOpacity(0.08),
                    shape: BoxShape.circle),
                child: Icon(icono, size: 48, color: AppColors.verdeClaro)),
            const SizedBox(height: 20),
            Text(titulo,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.texto)),
            const SizedBox(height: 8),
            Text(subtitulo,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textoSuave)),
            if (onReintentar != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ]),
        ),
      );
}
