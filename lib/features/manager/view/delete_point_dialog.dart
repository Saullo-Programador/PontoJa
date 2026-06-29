import 'package:flutter/material.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';

class DeletePointDialog extends StatefulWidget {
  final TimeRecordEntity record;
  final Future<void> Function(TimeRecordEntity) onDelete;

  const DeletePointDialog({
    super.key,
    required this.record,
    required this.onDelete,
  });

  @override
  State<DeletePointDialog> createState() => _DeletePointDialogState();
}

class _DeletePointDialogState extends State<DeletePointDialog> {
  bool _isDeleting = false;

  Future<void> _delete() async {
    setState(() {
      _isDeleting = true;
    });

    await widget.onDelete(widget.record);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir ponto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Tem certeza que deseja excluir este ponto?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isDeleting ? null : _delete,
          child: _isDeleting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Excluir'),
        ),
      ],
    );
  }
}