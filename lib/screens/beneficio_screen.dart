import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'fermentacion_screen.dart';
import 'secado_screen.dart';
import 'grafica_fermentacion_screen.dart';
import 'grafica_secado_screen.dart';
import 'historial_fermentacion_screen.dart';

class BeneficioScreen extends StatelessWidget {
  final String token;
  const BeneficioScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(
        titulo: 'Fermentación',
        subtitulo: 'Registrar pH · Brix · Temperatura',
        icono: Icons.science_rounded,
        colorFondo: const Color(0xFFE8F5E0),
        colorIcono: AppColors.verdeClaro,
        onTap: () =>
            Navigator.push(context, _r(FermentacionScreen(token: token))),
      ),
      _Item(
        titulo: 'Secado',
        subtitulo: 'Registrar humedad y rendimiento',
        icono: Icons.wb_sunny_rounded,
        colorFondo: const Color(0xFFE3F2FD),
        colorIcono: const Color(0xFF1565C0),
        onTap: () => Navigator.push(context, _r(SecadoScreen(token: token))),
      ),
      _Item(
        titulo: 'Gráficas Fermentación',
        subtitulo: 'Visualizar pH · Brix · Temperatura',
        icono: Icons.show_chart_rounded,
        colorFondo: const Color(0xFFE8F5E0),
        colorIcono: AppColors.verdeMedio,
        onTap: () => Navigator.push(
            context, _r(GraficaFermentacionScreen(token: token))),
      ),
      _Item(
        titulo: 'Gráficas Secado',
        subtitulo: 'Visualizar humedad y rendimiento',
        icono: Icons.bar_chart_rounded,
        colorFondo: const Color(0xFFE3F2FD),
        colorIcono: const Color(0xFF1565C0),
        onTap: () =>
            Navigator.push(context, _r(GraficaSecadoScreen(token: token))),
      ),
      _Item(
        titulo: 'Historial',
        subtitulo: 'Ver registros anteriores',
        icono: Icons.history_rounded,
        colorFondo: const Color(0xFFFCF3E3),
        colorIcono: const Color(0xFFE65100),
        onTap: () => Navigator.push(
            context, _r(HistorialFermentacionScreen(token: token))),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(slivers: [
        // ── AppBar ───────────────────────────────────────
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: AppColors.verde,
          leading: const BackButton(),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.verde, AppColors.verdeMedio],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.dorado.withOpacity(0.35))),
                          child: const Icon(Icons.agriculture_rounded,
                              color: AppColors.doradoClaro, size: 26)),
                      const SizedBox(width: 14),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Proceso de Beneficio',
                                style: TextStyle(
                                    color: AppColors.blanco,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700)),
                            Text('Fermentación · Secado · Historial',
                                style: TextStyle(
                                    color: AppColors.blanco.withOpacity(0.6),
                                    fontSize: 12)),
                          ]),
                    ]),
                  ]),
            ),
          ),
        ),

        // ── Lista de opciones ────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildCard(items[i], i),
              childCount: items.length,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCard(_Item item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 270 + index * 55),
      curve: Curves.easeOut,
      builder: (ctx, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(
              offset: Offset(0, 16 * (1 - v)), child: child)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: AppColors.fondoCard,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borde)),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: item.colorFondo,
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(item.icono, color: item.colorIcono, size: 24)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(item.titulo,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.texto)),
                      const SizedBox(height: 3),
                      Text(item.subtitulo,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textoSuave)),
                    ])),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.borde, size: 22),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  PageRoute _r(Widget s) => MaterialPageRoute(builder: (_) => s);
}

class _Item {
  final String titulo, subtitulo;
  final IconData icono;
  final Color colorFondo, colorIcono;
  final VoidCallback onTap;
  const _Item(
      {required this.titulo,
      required this.subtitulo,
      required this.icono,
      required this.colorFondo,
      required this.colorIcono,
      required this.onTap});
}
