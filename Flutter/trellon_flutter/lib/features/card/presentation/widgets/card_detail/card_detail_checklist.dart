import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardDetailChecklistItem {
  final String id;
  final String title;
  bool checked;
  CardDetailChecklistItem({required this.id, required this.title, this.checked = false});
}

class CardDetailChecklist extends StatefulWidget {
  final List<CardDetailChecklistItem> initialItems;
  final void Function(String id, bool checked)? onCheckChanged;
  final ValueChanged<String>? onAddTodo;

  const CardDetailChecklist({
    super.key,
    required this.initialItems,
    this.onCheckChanged,
    this.onAddTodo,
  });

  @override
  State<CardDetailChecklist> createState() => _CardDetailChecklistState();
}

class _CardDetailChecklistState extends State<CardDetailChecklist> {
  late List<CardDetailChecklistItem> _items;
  bool _isAdding = false;
  bool _collapsed = false;
  final TextEditingController _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems;
  }

  @override
  void didUpdateWidget(CardDetailChecklist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialItems != oldWidget.initialItems) {
      _items = widget.initialItems;
    }
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 10, 0),
          child: Row(
            children: [
              Icon(Icons.check_box_outlined, size: 20, color: Colors.grey.shade500),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Danh sách công việc',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
              ),
              // Add + button
              if (!_isAdding)
                IconButton(
                  icon: const Icon(Icons.add, size: 22, color: Color(0xFF1565C0)),
                  onPressed: () => setState(() => _isAdding = true),
                ),
            ],
          ),
        ),

        // ── Checklist items ───────────────────────────────────────────
        if (!_collapsed) ...[
          // Group title row (like "Cần làm ∧ ⋯")
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 10, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cần làm',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.expand_less, size: 20, color: Colors.grey),
                    onPressed: () => setState(() => _collapsed = true),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.more_horiz, size: 20, color: Colors.grey.shade500),
                ],
              ),
            ),

          // Items list
          ..._items.map((item) => _CheckItem(
                item: item,
                onChanged: (checked) {
                  setState(() => item.checked = checked);
                  widget.onCheckChanged?.call(item.id, checked);
                },
              )),

          // "Thêm mục..." placeholder
          if (!_isAdding)
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 4, 16, 8),
              child: GestureDetector(
                onTap: () => setState(() => _isAdding = true),
                child: Text(
                  'Thêm mục...',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: Colors.grey.shade500),
                ),
              ),
            ),
        ] else
          // Collapsed state — show expand button
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 4, 16, 8),
            child: GestureDetector(
              onTap: () => setState(() => _collapsed = false),
              child: Row(
                children: [
                  const Icon(Icons.expand_more, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Hiển thị ${_items.length} mục',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),

        // ── Add item input ────────────────────────────────────────────
        if (_isAdding)
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    autofocus: true,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Thêm mục...',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 14, color: Colors.grey.shade500),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF1565C0)),
                      ),
                    ),
                    onSubmitted: (v) => _confirmAdd(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () =>
                      setState(() {
                        _isAdding = false;
                        _addController.clear();
                      }),
                ),
                IconButton(
                  icon: const Icon(Icons.check, size: 20, color: Color(0xFF1565C0)),
                  onPressed: _confirmAdd,
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _confirmAdd() {
    final v = _addController.text.trim();
    if (v.isNotEmpty) widget.onAddTodo?.call(v);
    setState(() {
      _isAdding = false;
      _addController.clear();
    });
  }
}

class _CheckItem extends StatelessWidget {
  final CardDetailChecklistItem item;
  final ValueChanged<bool> onChanged;
  const _CheckItem({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Square checkbox
          GestureDetector(
            onTap: () => onChanged(!item.checked),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: item.checked ? const Color(0xFF1565C0) : Colors.transparent,
                border: Border.all(
                  color: item.checked
                      ? const Color(0xFF1565C0)
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: item.checked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                item.title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: item.checked ? Colors.grey.shade500 : Colors.black87,
                  decoration: item.checked ? TextDecoration.lineThrough : null,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
