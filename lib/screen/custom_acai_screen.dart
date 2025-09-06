import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:maria_pitanga/model/ingredient_model.dart';
import 'package:maria_pitanga/screen/checkout_dialog.dart';
import 'package:maria_pitanga/utils/format_euros_utils.dart';

const double kEuroPerGramBase = 0.03; // Açaí/Cupuaçu = 3€/100g
const double kEuroPerGramOther = 0.10; // demais = 1€/10g

const kAllIngredients = <Ingredient>[
  Ingredient(
    name: 'Açaí',
    emoji: '🫐',
    color: Color(0xFF4B006E),
    gramsPerAdd: 300,
    euroPerGram: kEuroPerGramBase,
  ),
  Ingredient(
    name: 'Cupuaçu',
    emoji: '🥭',
    color: Color(0xFFFFC66A),
    gramsPerAdd: 100,
    euroPerGram: kEuroPerGramBase,
  ),
  Ingredient(
    name: 'Leite em pó',
    emoji: '🥛',
    color: Color(0xFFF1E9D2),
    gramsPerAdd: 10,
    euroPerGram: kEuroPerGramOther,
  ),
  Ingredient(
    name: 'Banana',
    emoji: '🍌',
    color: Color(0xFFFFE176),
    gramsPerAdd: 10,
    euroPerGram: kEuroPerGramOther,
  ),
  Ingredient(
    name: 'Leite condensado',
    emoji: '🍯',
    color: Color(0xFFFFF2D6),
    gramsPerAdd: 10,
    euroPerGram: kEuroPerGramOther,
  ),
  Ingredient(
    name: 'Granola',
    emoji: '🥣',
    color: Color(0xFFB67A4D),
    gramsPerAdd: 10,
    euroPerGram: kEuroPerGramOther,
  ),
  Ingredient(
    name: 'Morango',
    emoji: '🍓',
    color: Color(0xFFFF4B5C),
    gramsPerAdd: 10,
    euroPerGram: kEuroPerGramOther,
  ),
  Ingredient(
    name: 'Paçoca',
    emoji: '🥜',
    color: Color(0xFFD39A6A),
    gramsPerAdd: 10,
    euroPerGram: kEuroPerGramOther,
  ),
];

// ===== Tela principal =====
class AcaiBuilderScreen extends StatefulWidget {
  const AcaiBuilderScreen({super.key});
  @override
  State<AcaiBuilderScreen> createState() => _AcaiBuilderScreenState();
}

class _AcaiBuilderScreenState extends State<AcaiBuilderScreen>
    with TickerProviderStateMixin {
  final int capacity = 8;
  final List<Ingredient> _layers = [];

  late final AnimationController _plopCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _plop = CurvedAnimation(
    parent: _plopCtrl,
    curve: Curves.easeOutBack,
  );
  late final AnimationController _shakeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  Ingredient? _lastRemoved;
  int? _lastRemovedIndex;

  @override
  void dispose() {
    _plopCtrl.dispose();
    _shakeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // normalizador seguro (evita RangeError)
  static const Map<String, String> _foldMap = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'Á': 'a',
    'À': 'a',
    'Â': 'a',
    'Ã': 'a',
    'Ä': 'a',
    'é': 'e',
    'ê': 'e',
    'É': 'e',
    'Ê': 'e',
    'í': 'i',
    'Í': 'i',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'Ó': 'o',
    'Ô': 'o',
    'Õ': 'o',
    'ú': 'u',
    'Ú': 'u',
    'ç': 'c',
    'Ç': 'c',
  };
  String _fold(String s) {
    final lower = s.toLowerCase();
    final sb = StringBuffer();
    for (final ch in lower.runes) {
      final chStr = String.fromCharCode(ch);
      sb.write(_foldMap[chStr] ?? chStr);
    }
    return sb.toString();
  }

  List<Ingredient> get _filteredIngredients {
    if (_query.trim().isEmpty) return kAllIngredients;
    final q = _fold(_query);
    return kAllIngredients.where((ing) => _fold(ing.name).contains(q)).toList();
  }

  int get totalGrams => _layers.fold(0, (a, i) => a + i.gramsPerAdd);
  double get totalPrice => _layers.fold(0.0, (a, i) => a + i.pricePerAdd);

  void _addLayer(Ingredient ing) {
    if (_layers.length >= capacity) {
      _shakeCtrl
        ..reset()
        ..forward();
      return;
    }
    setState(() => _layers.add(ing)); // aparece no TOPO visual (render reverso)
    _plopCtrl
      ..reset()
      ..forward();
  }

  void _removeLayerAt(int index) {
    if (index < 0 || index >= _layers.length) return;
    setState(() {
      _lastRemoved = _layers.removeAt(index);
      _lastRemovedIndex = index;
    });
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text('Camada removida'),
          action: SnackBarAction(label: 'Desfazer', onPressed: _undoRemove),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _undoRemove() {
    if (_lastRemoved != null && _lastRemovedIndex != null) {
      setState(() {
        final i = _lastRemovedIndex!.clamp(0, _layers.length);
        _layers.insert(i, _lastRemoved!);
      });
    }
    _lastRemoved = null;
    _lastRemovedIndex = null;
  }

  void _removeTopLayer() {
    if (_layers.isEmpty) return;
    _removeLayerAt(_layers.length - 1);
  }

  void _reset() => setState(() => _layers.clear());

  @override
  Widget build(BuildContext context) {
    final canDrop = _layers.length < capacity;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Monte seu Açaí'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Limpar',
            onPressed: _layers.isEmpty ? null : _reset,
            icon: _layers.isEmpty
                ? const Icon(Icons.refresh, color: Colors.grey)
                : const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Peso: ${totalGrams}g',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Total: ${FormatEurosUtils.formatEuro(totalPrice)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            // Board de ingredientes — grid estável em qualquer largura
            Expanded(
              flex: isWide ? 6 : 5,
              child: _IngredientBoard(
                items: _filteredIngredients,
                onDragged: _addLayer,
                searchField: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Pesquisar ingrediente…',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16, height: 16),
            // Copo — largura máxima + overflow safe
            Expanded(
              flex: isWide ? 5 : 6,
              child: _CupZone(
                layers: _layers,
                capacity: capacity,
                canDrop: canDrop,
                onAccept: _addLayer,
                onRemoveIndex: _removeLayerAt,
                onRemoveTop: _removeTopLayer,
                plop: _plop,
                shakeCtrl: _shakeCtrl,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        layers: _layers,
        onDeleteIndex: _removeLayerAt,
        totalGrams: totalGrams,
        totalPrice: totalPrice,
      ),
    );
  }
}

// ===== Board de ingredientes (fix colunas) =====
class _IngredientBoard extends StatelessWidget {
  final List<Ingredient> items;
  final void Function(Ingredient) onDragged;
  final Widget searchField;
  const _IngredientBoard({
    required this.items,
    required this.onDragged,
    required this.searchField,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            searchField,
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  // colunas por largura real — nunca 0
                  final colWidth = 160.0;
                  final crossAxisCount = (c.maxWidth / colWidth).floor().clamp(
                    1,
                    8,
                  );
                  return GridView.builder(
                    key: ValueKey('grid-$crossAxisCount-${items.length}'),
                    itemCount: items.length,
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, i) {
                      final ing = items[i];
                      return _DraggableIngredient(
                        ingredient: ing,
                        onDragged: onDragged,
                      );
                    },
                  );
                },
              ),
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Nenhum ingrediente encontrado'),
              ),
          ],
        ),
      ),
    );
  }
}

class _DraggableIngredient extends StatelessWidget {
  final Ingredient ingredient;
  final void Function(Ingredient) onDragged;
  const _DraggableIngredient({
    required this.ingredient,
    required this.onDragged,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Ingredient>(
      data: ingredient,
      feedback: _IngredientChip(ingredient: ingredient, elevated: true),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _IngredientChip(ingredient: ingredient),
      ),
      child: GestureDetector(
        onTap: () => onDragged(ingredient),
        child: _IngredientChip(ingredient: ingredient),
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  final Ingredient ingredient;
  final bool elevated;
  const _IngredientChip({required this.ingredient, this.elevated = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevated ? 8 : 1,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: ingredient.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ingredient.color.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ingredient.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    ingredient.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ingredient.gramsPerAdd}g • ${FormatEurosUtils.formatEuro(ingredient.pricePerAdd)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Copo / Camadas (overflow safe) =====
class _CupZone extends StatefulWidget {
  final List<Ingredient> layers;
  final int capacity;
  final bool canDrop;
  final void Function(Ingredient) onAccept;
  final void Function(int index) onRemoveIndex;
  final VoidCallback onRemoveTop;
  final Animation<double> plop;
  final AnimationController shakeCtrl;

  const _CupZone({
    required this.layers,
    required this.capacity,
    required this.canDrop,
    required this.onAccept,
    required this.onRemoveIndex,
    required this.onRemoveTop,
    required this.plop,
    required this.shakeCtrl,
  });

  @override
  State<_CupZone> createState() => _CupZoneState();
}

class _CupZoneState extends State<_CupZone> {
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    widget.shakeCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final cap = widget.capacity;
    final len = widget.layers.length;
    final percent = len / cap;
    final shake = math.sin(widget.shakeCtrl.value * math.pi * 6) * 6.0;

    return LayoutBuilder(
      builder: (context, c) {
        return Transform.translate(
          offset: Offset(shake, 0),
          child: DragTarget<Ingredient>(
            onWillAcceptWithDetails: (_) {
              setState(() => _hovering = true);
              return widget.canDrop;
            },
            onMove: (_) => setState(() => _hovering = true),
            onLeave: (_) => setState(() => _hovering = false),
            onAcceptWithDetails: (ing) {
              setState(() => _hovering = false);
              widget.onAccept(ing.data);
            },
            builder: (context, candidates, rejects) {
              return Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight - 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.canDrop
                                ? 'Dica: toque no topo para remover; segure em qualquer camada para excluir.'
                                : 'O copo está cheio — limpe ou remova uma item',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.canDrop
                                  ? Colors.black87
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Indicador de progresso por camadas (opcional, visual)
                          LinearProgressIndicator(
                            value: percent.clamp(0.0, 1.0),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 14),
                          AnimatedScale(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutBack,
                            scale: _hovering && widget.canDrop ? 1.02 : 1.0,
                            child: GestureDetector(
                              onTap: widget.onRemoveTop, // toque remove topo
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: _Cup(
                                      layers: widget.layers,
                                      plop: widget.plop,
                                      isFull: !widget.canDrop,
                                      onRemoveIndex: widget.onRemoveIndex,
                                    ),
                                  ),
                                  if (!widget.canDrop)
                                    Positioned(
                                      top: 12,
                                      child: FittedBox(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.red.withValues(
                                                alpha: 0.35,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            'Capacidade máxima atingida',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Cup extends StatelessWidget {
  final List<Ingredient> layers;
  final Animation<double> plop;
  final bool isFull;
  final void Function(int index) onRemoveIndex;

  const _Cup({
    required this.layers,
    required this.plop,
    required this.isFull,
    required this.onRemoveIndex,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CupOutlinePainter(
        borderColor: Colors.black.withValues(alpha: 0.2),
        glowColor: isFull
            ? Colors.red.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.0),
      ),
      child: ClipPath(
        clipper: _CupClipper(),
        child: Container(
          alignment: Alignment.bottomCenter,
          child: _AnimatedLayers(
            layers: layers,
            plop: plop,
            onRemoveIndex: onRemoveIndex,
          ),
        ),
      ),
    );
  }
}

class _AnimatedLayers extends StatelessWidget {
  final List<Ingredient> layers;
  final Animation<double> plop;
  final void Function(int index) onRemoveIndex;

  const _AnimatedLayers({
    required this.layers,
    required this.plop,
    required this.onRemoveIndex,
  });

  @override
  Widget build(BuildContext context) {
    final count = layers.length;
    if (count == 0) return const SizedBox.shrink();

    const gap = 4.0; // espaço entre camadas

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // para suavizar o “plop” só no topo
          final topPlop = Tween<double>(begin: .95, end: 1.0).animate(plop);

          // construímos a lista em ordem reversa (novo item no topo visual)
          final children = <Widget>[];
          for (int i = 0; i < count; i++) {
            final revIndex = count - 1 - i; // índice real na lista original
            final ing = layers[revIndex];
            final isTop = i == 0;

            final layer = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: () => onRemoveIndex(revIndex),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: isTop ? topPlop.value : 1.0,
                curve: Curves.easeOut,
                child: Container(
                  // ocupa a fração vertical via Expanded (definido mais abaixo)
                  decoration: BoxDecoration(
                    color: ing.color.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(
                        isTop ? 14 * (1 + plop.value * 0.2) : 6,
                      ),
                      bottom: const Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: isTop ? 10 * plop.value : 4,
                        spreadRadius: isTop ? 1.5 * plop.value : 0,
                        offset: const Offset(0, 1),
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _SwirlPainter(opacity: 0.08),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${ing.gramsPerAdd}g • ${FormatEurosUtils.formatEuro(ing.pricePerAdd)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (isTop)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              ing.emoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );

            // cada camada vira um Expanded para dividir igualmente a altura
            children.add(Expanded(child: layer));

            // espaçador entre camadas (não depois da última)
            if (i < count - 1) {
              children.add(const SizedBox(height: gap));
            }
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        },
      ),
    );
  }
}

class _CupOutlinePainter extends CustomPainter {
  final Color borderColor;
  final Color glowColor;
  _CupOutlinePainter({required this.borderColor, required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final topWidth = w * 0.86, bottomWidth = w * 0.62;
    final topX = (w - topWidth) / 2, bottomX = (w - bottomWidth) / 2;
    const r = 18.0;

    final path = Path()
      ..moveTo(topX + r, 0)
      ..lineTo(topX + topWidth - r, 0)
      ..quadraticBezierTo(topX + topWidth, 0, topX + topWidth - 4, 8)
      ..lineTo(bottomX + bottomWidth - 4, h - 8)
      ..quadraticBezierTo(
        bottomX + bottomWidth,
        h,
        bottomX + bottomWidth - r,
        h,
      )
      ..lineTo(bottomX + r, h)
      ..quadraticBezierTo(bottomX, h, bottomX + 4, h - 8)
      ..lineTo(topX + 4, 8)
      ..quadraticBezierTo(topX, 0, topX + r, 0)
      ..close();

    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [glowColor, Colors.transparent, glowColor],
        stops: const [0, .5, 1],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, glowPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CupOutlinePainter old) =>
      old.borderColor != borderColor || old.glowColor != glowColor;
}

class _CupClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    final topWidth = w * 0.86, bottomWidth = w * 0.62;
    final topX = (w - topWidth) / 2, bottomX = (w - bottomWidth) / 2;
    return Path()
      ..moveTo(topX, 0)
      ..lineTo(topX + topWidth, 0)
      ..lineTo(bottomX + bottomWidth, h)
      ..lineTo(bottomX, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant _CupClipper oldClipper) => false;
}

class _SwirlPainter extends CustomPainter {
  final double opacity;
  const _SwirlPainter({this.opacity = 0.08});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 1.2;
    for (double i = 0; i < 6; i++) {
      final r = maxR * (i + 1) / 6;
      final path = Path();
      for (double a = 0; a <= math.pi * 2; a += 0.3) {
        final noise = math.sin(a * 3 + i) * 1.5;
        final x = center.dx + (r + noise) * math.cos(a);
        final y = center.dy + (r + noise) * math.sin(a);
        if (a == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwirlPainter old) => false;
}

// ===== Barra inferior =====
class _BottomBar extends StatelessWidget {
  final List<Ingredient> layers;
  final void Function(int index) onDeleteIndex;
  final int totalGrams;
  final double totalPrice;
  const _BottomBar({
    required this.layers,
    required this.onDeleteIndex,
    required this.totalGrams,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final total = layers.length;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, c) {
          final isTight = c.maxWidth < 520;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text(
                            'Seu pote: ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        for (var i = 0; i < layers.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              label: Text(
                                '${layers[i].name} (${layers[i].gramsPerAdd}g)',
                                overflow: TextOverflow.ellipsis,
                              ),
                              onDeleted: () => onDeleteIndex(i),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: layers[i].color.withValues(
                                alpha: 0.15,
                              ),
                              side: BorderSide(
                                color: layers[i].color.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        if (layers.isEmpty)
                          const Text(
                            'vazio',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: isTight ? 48 : 160,
                    maxWidth: isTight ? 130 : 220,
                    minHeight: 40,
                  ),
                  child: FilledButton.icon(
                    onPressed: total == 0
                        ? null
                        : () => Get.dialog(
                            CheckoutDialog(
                              layers: layers,
                              totalGrams: totalGrams,
                              totalPrice: totalPrice,
                            ),
                            barrierDismissible: true,
                          ),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(FormatEurosUtils.formatEuro(totalPrice)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
