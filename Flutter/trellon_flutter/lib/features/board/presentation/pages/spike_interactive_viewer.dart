import 'package:flutter/material.dart';

/// SPIKE: InteractiveViewer + LongPressDraggable + Auto-scroll
/// Phase 1: Đánh giá rủi ro
///
/// Mục tiêu test:
/// 1. InteractiveViewer có chặn gesture của LongPressDraggable không?
///    -> Có thể giải quyết bằng cách dùng cờ `panEnabled: !isDragging`
/// 2. Auto-scroll khi kéo component ra rìa màn hình.
///    -> Có thể dùng Listener/Timer để cuốn ScrollController nếu offset bị vượt giới hạn.

class SpikeInteractiveViewer extends StatefulWidget {
  const SpikeInteractiveViewer({super.key});

  @override
  State<SpikeInteractiveViewer> createState() => _SpikeInteractiveViewerState();
}

class _SpikeInteractiveViewerState extends State<SpikeInteractiveViewer> {
  final TransformationController _transformationController =
      TransformationController();
  final ScrollController _scrollController = ScrollController();

  bool _isDragging = false;
  final List<String> _items = List.generate(10, (index) => 'List ${index + 1}');

  @override
  void dispose() {
    _transformationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onDragStarted() {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragEnded(DraggableDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phase 1: Drag Spike')),
      body: SafeArea(
        // Spike 1 & 2: InteractiveViewer + Pan Locking
        child: InteractiveViewer(
          transformationController: _transformationController,
          panEnabled: !_isDragging, // Tạm khóa zoom/pan khi đang drag
          scaleEnabled: !_isDragging,
          minScale: 0.5,
          maxScale: 2.0,
          constrained: false, // Để board rộng hơn màn hình
          child: Container(
            width: 2000, // Giả lập board rộng
            height: MediaQuery.of(context).size.height,
            color: Colors.blueGrey[50],
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LongPressDraggable<String>(
                    data: item,
                    onDragStarted: _onDragStarted,
                    onDragEnd: _onDragEnded,
                    onDraggableCanceled: (velocity, offset) {
                      _onDragEnded(
                        DraggableDetails(velocity: velocity, offset: offset),
                      );
                    },
                    feedback: Material(
                      elevation: 8,
                      child: Container(
                        width: 280,
                        height: 400,
                        color: Colors.blueAccent.withValues(alpha: 0.8),
                        child: Center(
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    childWhenDragging: Container(
                      width: 280,
                      height: 400,
                      color: Colors.grey[300], // Ghost UI
                    ),
                    child: DragTarget<String>(
                      onAcceptWithDetails: (details) {
                        setState(() {
                          // Swap logic
                          final oldIndex = _items.indexOf(details.data);
                          _items.removeAt(oldIndex);
                          _items.insert(index, details.data);
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: 280,
                          height: 400,
                          color: candidateData.isNotEmpty
                              ? Colors.green[200]
                              : Colors.white,
                          child: Center(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
