import 'package:flutter/material.dart';
import '../../domain/entities/workspace_entity.dart';

class CreateWorkspaceDialog extends StatefulWidget {
  final WorkspaceEntity? workspace;

  const CreateWorkspaceDialog({super.key, this.workspace});

  @override
  State<CreateWorkspaceDialog> createState() => _CreateWorkspaceDialogState();
}

class _CreateWorkspaceDialogState extends State<CreateWorkspaceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late WorkspaceType _type;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workspace?.name ?? '');
    _descriptionController = TextEditingController(text: widget.workspace?.description ?? '');
    _type = widget.workspace?.type ?? WorkspaceType.personal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.workspace == null ? 'Tạo không gian mới' : 'Sửa không gian'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên không gian'),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả (không bắt buộc)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WorkspaceType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Loại không gian'),
                items: WorkspaceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == WorkspaceType.personal ? 'Cá nhân' : 'Nhóm (Team)'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'description': _descriptionController.text,
                'type': _type,
              });
            }
          },
          child: Text(widget.workspace == null ? 'Tạo' : 'Lưu'),
        ),
      ],
    );
  }
}
