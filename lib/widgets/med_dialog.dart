import 'package:flutter/material.dart';
import 'package:lab_1/core/validator.dart';
import 'package:lab_1/models/medication.dart';
import 'package:lab_1/widgets/app_text_field.dart';

class MedDialog extends StatefulWidget {
  const MedDialog({required this.day, this.initial, super.key});

  final int day;
  final Medication? initial;

  @override
  State<MedDialog> createState() => _MedDialogState();
}

class _MedDialogState extends State<MedDialog> {
  late final _nameCtrl =
      TextEditingController(text: widget.initial?.name ?? '');
  late PillStatus _status = widget.initial?.status ?? PillStatus.pending;
  late String? _time = widget.initial?.time;
  String? _nameError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    var initial = TimeOfDay.now();
    if (_time != null) {
      final parts = _time!.split(':');
      initial = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    setState(() {
      _time =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  void _submit() {
    final err = Validator.name(_nameCtrl.text);
    setState(() => _nameError = err);
    if (err != null) return;
    if (_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оберіть час прийому')),
      );
      return;
    }
    final id = widget.initial?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    Navigator.pop(
      context,
      Medication(
        id: id,
        name: _nameCtrl.text.trim(),
        time: _time!,
        status: _status,
        day: widget.day,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Новий препарат' : 'Редагувати'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              hint: 'Назва препарату',
              controller: _nameCtrl,
              errorText: _nameError,
              icon: Icons.medication_outlined,
            ),
            const SizedBox(height: 16),
            _TimeButton(time: _time, onTap: _pickTime),
            const SizedBox(height: 16),
            _StatusSelector(
              status: _status,
              onChanged: (s) => setState(() => _status = s),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Скасувати'),
        ),
        TextButton(onPressed: _submit, child: const Text('Зберегти')),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.time, required this.onTap});

  final String? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: const Icon(Icons.access_time_rounded),
    label: Text(time ?? 'Оберіть час'),
    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
  );
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.status, required this.onChanged});

  final PillStatus status;
  final ValueChanged<PillStatus> onChanged;

  static String _label(PillStatus s) => switch (s) {
    PillStatus.taken => 'Прийнято',
    PillStatus.pending => 'Очікується',
    PillStatus.missed => 'Пропущено',
  };

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PillStatus>(
      initialValue: status,
      decoration: const InputDecoration(
        labelText: 'Статус',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: PillStatus.values
          .map((s) => DropdownMenuItem(value: s, child: Text(_label(s))))
          .toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}
