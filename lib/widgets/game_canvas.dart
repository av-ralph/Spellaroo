import 'dart:math';
import 'package:flutter/material.dart';
import '../services/game_service.dart';

class GameCanvas extends StatefulWidget {
  final String word;
  final List<String> selectedIds;
  final Function(String) onLetterTap;
  final bool enabled;

  const GameCanvas({
    super.key,
    required this.word,
    required this.selectedIds,
    required this.onLetterTap,
    this.enabled = true,
  });

  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> {
  late List<LetterNode> nodes;
  double radius = 130;

  @override
  void initState() {
    super.initState();
    _buildNodes();
  }

  @override
  void didUpdateWidget(GameCanvas old) {
    super.didUpdateWidget(old);
    if (old.word != widget.word) _buildNodes();
  }

  void _buildNodes() {
    nodes = GameService.buildLetterNodes(widget.word, radius: radius);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final scaledRadius = size * 0.35;
        final positionedNodes = nodes
            .map(
              (node) => LetterNode(
                id: node.id,
                letter: node.letter,
                wordIndex: node.wordIndex,
                x: node.x / radius * scaledRadius,
                y: node.y / radius * scaledRadius,
              ),
            )
            .toList();
        final center = Offset(size / 2, size / 2);

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Connection lines
              CustomPaint(
                size: Size(size, size),
                painter: _ConnectionPainter(
                  nodes: positionedNodes,
                  selectedIds: widget.selectedIds,
                  center: center,
                ),
              ),
              // Letter nodes
              ...positionedNodes.map((node) {
                final pos = Offset(center.dx + node.x, center.dy + node.y);
                final isSelected = widget.selectedIds.contains(node.id);
                final selectionOrder = widget.selectedIds.indexOf(node.id);

                return Positioned(
                  left: pos.dx - 24,
                  top: pos.dy - 24,
                  child: GestureDetector(
                    key: ValueKey('letter-${node.id}'),
                    onTap: widget.enabled
                        ? () => widget.onLetterTap(node.id)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [Colors.white, Colors.grey.shade100],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFFF97316).withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.1),
                            blurRadius: isSelected ? 8 : 4,
                            offset: Offset(0, isSelected ? 4 : 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            node.letter,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF262626),
                            ),
                          ),
                          if (isSelected && selectionOrder >= 0)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${selectionOrder + 1}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF97316),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ConnectionPainter extends CustomPainter {
  final List<LetterNode> nodes;
  final List<String> selectedIds;
  final Offset center;

  _ConnectionPainter({
    required this.nodes,
    required this.selectedIds,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedIds.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFFF97316).withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < selectedIds.length - 1; i++) {
      final fromNode = nodes.firstWhere((n) => n.id == selectedIds[i]);
      final toNode = nodes.firstWhere((n) => n.id == selectedIds[i + 1]);
      final fromPos = Offset(center.dx + fromNode.x, center.dy + fromNode.y);
      final toPos = Offset(center.dx + toNode.x, center.dy + toNode.y);
      canvas.drawLine(fromPos, toPos, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter old) =>
      old.selectedIds != selectedIds ||
      old.center != center ||
      old.nodes != nodes;
}
