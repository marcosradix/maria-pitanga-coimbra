import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:maria_pitanga/utils/format_euros_utils.dart';
import 'package:maria_pitanga/utils/whats_app_utils.dart';

import '../model/ingredient_model.dart';

class CheckoutDialog extends StatefulWidget {
  final List<Ingredient> layers;
  final int totalGrams;
  final double totalPrice;

  const CheckoutDialog({
    super.key,
    required this.layers,
    required this.totalGrams,
    required this.totalPrice,
  });

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Agrega os itens (considera todos os layers, topo→fundo não importa para agregação)
    final aggregated = aggregateLayers(widget.layers);
    final summaryText = buildOrderSummary(
      aggregated: aggregated,
      totalGrams: widget.totalGrams,
      totalPrice: widget.totalPrice,
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SizedBox(
          height: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: const [
                    Icon(Icons.receipt_long),
                    SizedBox(width: 8),
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Lista agregada
              Expanded(
                child: Scrollbar(
                  controller: _scrollCtrl,
                  thumbVisibility: true,
                  child: ListView.separated(
                    controller: _scrollCtrl,
                    primary: false,
                    itemCount: aggregated.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final it = aggregated[i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: it.base.color.withOpacity(0.2),
                          child: Text(
                            it.base.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        title: Text(
                          '${it.qty}× ${it.base.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${it.base.gramsPerAdd}g • ${FormatEurosUtils.formatEuro(it.base.pricePerAdd)} cada',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${it.totalGrams}g',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              FormatEurosUtils.formatEuro(it.totalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const Divider(height: 1),

              // Totais
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Peso total: ${widget.totalGrams}g',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      'Total: ${FormatEurosUtils.formatEuro(widget.totalPrice)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Ações (Copiar resumo / Fechar / Confirmar)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: Get.back,
                      child: const Text('Fechar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        WhatsAppUtils.openWhatsApp(
                          phoneNumber: "+351926434534",
                          message: summaryText,
                        );
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        size: 16,
                        color: Color(0xFF25D366),
                      ),
                      label: const Text('Envia para o whatsapp'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AggregatedItem {
  final Ingredient base;
  final int qty;
  final int totalGrams;
  final double totalPrice;
  const AggregatedItem({
    required this.base,
    required this.qty,
    required this.totalGrams,
    required this.totalPrice,
  });
}

List<AggregatedItem> aggregateLayers(List<Ingredient> layers) {
  final map = <String, AggregatedItem>{}; // chave: nome do ingrediente
  for (final ing in layers) {
    final key = ing.name;
    if (map.containsKey(key)) {
      final cur = map[key]!;
      map[key] = AggregatedItem(
        base: cur.base,
        qty: cur.qty + 1,
        totalGrams: cur.totalGrams + ing.gramsPerAdd,
        totalPrice: cur.totalPrice + ing.pricePerAdd,
      );
    } else {
      map[key] = AggregatedItem(
        base: ing,
        qty: 1,
        totalGrams: ing.gramsPerAdd,
        totalPrice: ing.pricePerAdd,
      );
    }
  }
  // ordena pelo tipo “principal” primeiro (Açaí/Cupuaçu), depois alfabético
  final list = map.values.toList();
  list.sort((a, b) {
    int pri(AggregatedItem x) {
      final n = x.base.name.toLowerCase();
      if (n.contains('açaí')) return 0;
      if (n.contains('cupuaçu') || n.contains('cupua\u00e7u')) return 1;
      return 2;
    }

    final pa = pri(a), pb = pri(b);
    if (pa != pb) return pa - pb;
    return a.base.name.compareTo(b.base.name);
  });
  return list;
}

String buildOrderSummary({
  required List<AggregatedItem> aggregated,
  required int totalGrams,
  required double totalPrice,
}) {
  final sb = StringBuffer();
  sb.writeln('Pedido:');
  for (final it in aggregated) {
    sb.writeln(
      '• ${it.qty}× ${it.base.name} — ${it.totalGrams}g — ${FormatEurosUtils.formatEuro(it.totalPrice)}',
    );
  }
  sb.writeln('—');
  sb.writeln('Peso total: ${totalGrams}g');
  sb.writeln('Total a pagar: ${FormatEurosUtils.formatEuro(totalPrice)}');
  return sb.toString();
}
