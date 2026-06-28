import 'package:flutter/material.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';

class EditPointDialog extends StatefulWidget {
  final TimeRecordEntity record;
  final Future<void> Function(TimeRecordEntity) onSave;

  const EditPointDialog({
    super.key,
    required this.record,
    required this.onSave,
  });

  @override
  State<EditPointDialog> createState() => _EditPointDialogState();
}

class _EditPointDialogState extends State<EditPointDialog> {
  late TimeOfDay _entryTime;
  late TimeOfDay? _exitTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _entryTime = TimeOfDay.fromDateTime(widget.record.entry);
    _exitTime = widget.record.exit != null
        ? TimeOfDay.fromDateTime(widget.record.exit!)
        : null;
  }

  Future<void> _pickTime(bool isEntry) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isEntry ? _entryTime : (_exitTime ?? TimeOfDay.now()),
    );

    if (picked == null) return;

    setState(() {
      if (isEntry) {
        _entryTime = picked;
      } else {
        _exitTime = picked;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final date = widget.record.date;
    final newEntry = DateTime(
        date.year, date.month, date.day, _entryTime.hour, _entryTime.minute);
    final newExit = _exitTime != null
        ? DateTime(date.year, date.month, date.day, _exitTime!.hour,
            _exitTime!.minute)
        : null;

    final updated = widget.record.copyWith(entry: newEntry, exit: newExit);
    await widget.onSave(updated);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar ponto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.login_rounded, color: Colors.green),
            title: const Text('Entrada'),
            trailing: Text(
              _entryTime.format(context),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => _pickTime(true),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.orange),
            title: const Text('Saída'),
            trailing: Text(
              _exitTime?.format(context) ?? 'Não registrado',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => _pickTime(false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}