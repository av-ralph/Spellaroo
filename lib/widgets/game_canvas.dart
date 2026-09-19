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
  Offset? _dragPosition;
  bool _isDragging = false;

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

  String? _hitTest(
    Offset position,
    List<LetterNode> positionedNodes,
    Offset center,
    double nodeSize,
  ) {
    for (final node in positionedNodes) {
      final pos = Offset(center.dx + node.x, center.dy + node.y);
      final distance = (position - pos).distance;
      if (distance < nodeSize * 0.625) {
        return node.id;
      }
    }
    return null;
  }

  void _onPanStart(
    DragStartDetails details,
    List<LetterNode> positionedNodes,
    Offset center,
    double nodeSize,
  ) {
    if (!widget.enabled) return;
    final hitId = _hitTest(details.localPosition, positionedNodes, center, nodeSize);
    if (hitId != null) {
      setState(() {
        _isDragging = true;
        _dragPosition = details.localPosition;
      });
      if (!widget.selectedIds.contains(hitId)) {
        widget.onLetterTap(hitId);
      }
    }
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    List<LetterNode> positionedNodes,
    Offset center,
    double nodeSize,
  ) {
    if (!widget.enabled || !_isDragging) return;
    setState(() {
      _dragPosition = details.localPosition;
    });
    final hitId = _hitTest(details.localPosition, positionedNodes, center, nodeSize);
    if (hitId != null && !widget.selectedIds.contains(hitId)) {
      widget.onLetterTap(hitId);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final nodeSize = size * 0.13;
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

        return GestureDetector(
          onPanStart: (details) =>
              _onPanStart(details, positionedNodes, center, nodeSize),
          onPanUpdate: (details) =>
              _onPanUpdate(details, positionedNodes, center, nodeSize),
          onPanEnd: _onPanEnd,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xEEFFFFFF), Color(0xFFDDF2E8)],
                        ),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x120F6B69),
                            blurRadius: 20,
                            offset: Offset(0, 7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Connection lines and drag line
                CustomPaint(
                  size: Size(size, size),
                  painter: _ConnectionPainter(
                    nodes: positionedNodes,
                    selectedIds: widget.selectedIds,
                    center: center,
                    dragPosition: _dragPosition,
                    isDragging: _isDragging,
                  ),
                ),
                // Letter nodes
                ...positionedNodes.map((node) {
                  final pos = Offset(center.dx + node.x, center.dy + node.y);
                  final isSelected = widget.selectedIds.contains(node.id);
                  final selectionOrder = widget.selectedIds.indexOf(node.id);

                  return Positioned(
                    left: pos.dx - nodeSize / 2,
                    top: pos.dy - nodeSize / 2,
                    child: AnimatedContainer(
                      key: ValueKey('letter-${node.id}'),
                      duration: const Duration(milliseconds: 200),
                      width: nodeSize,
                      height: nodeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFCEE6DD),
                          width: 2,
                        ),
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF11A984), Color(0xFF63D7AD)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [Colors.white, const Color(0xFFFFF8DC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFF11A984).withValues(alpha: 0.4)
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
                              fontSize: nodeSize * 0.46,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF214D5D),
                            ),
                          ),
                          if (isSelected && selectionOrder >= 0)
                            Positioned(
                              top: nodeSize * 0.04,
                              right: nodeSize * 0.04,
                              child: Container(
                                width: nodeSize * 0.33,
                                height: nodeSize * 0.33,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFCEE6DD),
                                    width: 2,
                                  ),
                                  color: Colors.white,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${selectionOrder + 1}',
                                  style: TextStyle(
                                    fontSize: nodeSize * 0.19,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF11A984),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
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
  final Offset? dragPosition;
  final bool isDragging;

  _ConnectionPainter({
    required this.nodes,
    required this.selectedIds,
    required this.center,
    this.dragPosition,
    this.isDragging = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final connectionPaint = Paint()
      ..color = const Color(0xFF11A984).withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw connection lines between selected letters
    if (selectedIds.length >= 2) {
      for (var i = 0; i < selectedIds.length - 1; i++) {
        final fromNode = nodes.firstWhere((n) => n.id == selectedIds[i]);
        final toNode = nodes.firstWhere((n) => n.id == selectedIds[i + 1]);
        final fromPos = Offset(center.dx + fromNode.x, center.dy + fromNode.y);
        final toPos = Offset(center.dx + toNode.x, center.dy + toNode.y);
        canvas.drawLine(fromPos, toPos, connectionPaint);
      }
    }

    // Draw drag line from last selected letter to drag position
    if (isDragging && dragPosition != null && selectedIds.isNotEmpty) {
      final lastNode = nodes.firstWhere((n) => n.id == selectedIds.last);
      final lastPos = Offset(center.dx + lastNode.x, center.dy + lastNode.y);

      final dragLinePaint = Paint()
        ..color = const Color(0xFF11A984).withValues(alpha: 0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(lastPos, dragPosition!, dragLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter old) =>
      old.selectedIds != selectedIds ||
      old.center != center ||
      old.nodes != nodes ||
      old.dragPosition != dragPosition ||
      old.isDragging != isDragging;
}
