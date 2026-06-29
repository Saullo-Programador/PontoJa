import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ponto_eletronico/features/manager/controller/workplace_controller.dart';

class WorkplaceConfigScreen extends StatefulWidget {
  const WorkplaceConfigScreen({super.key});

  @override
  State<WorkplaceConfigScreen> createState() => _WorkplaceConfigScreenState();
}

class _WorkplaceConfigScreenState extends State<WorkplaceConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController(text: '200');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<WorkplaceController>().load();
      _prefillFromExisting();
    });
  }

  void _prefillFromExisting() {
    final wp = context.read<WorkplaceController>().workplace;
    if (wp == null) return;
    _nameCtrl.text = wp.name;
    _latCtrl.text = wp.latitude.toString();
    _lngCtrl.text = wp.longitude.toString();
    _radiusCtrl.text = wp.radiusMeters.toString();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveManual() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<WorkplaceController>().saveManual(
          name: _nameCtrl.text.trim(),
          latitude: double.parse(_latCtrl.text.trim()),
          longitude: double.parse(_lngCtrl.text.trim()),
          radiusMeters: double.parse(_radiusCtrl.text.trim()),
        );
    _showFeedback();
  }

  Future<void> _saveCurrentLocation() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do local primeiro.')),
      );
      return;
    }

    final radius = double.tryParse(_radiusCtrl.text.trim()) ?? 200;
    await context.read<WorkplaceController>().saveCurrentLocation(
          name: _nameCtrl.text.trim(),
          radiusMeters: radius,
        );
    _showFeedback();
  }

  void _showFeedback() {
    if (!mounted) return;
    final ctrl = context.read<WorkplaceController>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ctrl.status == WorkplaceStatus.success
            ? 'Localização salva com sucesso!'
            : ctrl.errorMessage),
        backgroundColor: ctrl.status == WorkplaceStatus.success
            ? Colors.green
            : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WorkplaceController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Local de trabalho')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Status atual ──────────────────────────────────────────
              if (ctrl.hasWorkplace) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green),
                          const SizedBox(width: 8),
                          Text('Local configurado',
                              style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(ctrl.workplace!.name,
                          style: const TextStyle(fontWeight: FontWeight.w600,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                          'Lat: ${ctrl.workplace!.latitude.toStringAsFixed(6)}\n'
                          'Lng: ${ctrl.workplace!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(
                          'Raio máximo: ${ctrl.workplace!.radiusMeters.toStringAsFixed(0)} m',
                          style: TextStyle(
                              fontSize: 13, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text('Configurar localização',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              // ── Nome do local ─────────────────────────────────────────
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nome do local',
                  hintText: 'ex: Lanchonete Central',
                  prefixIcon: const Icon(Icons.store_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 14),

              // ── Raio ─────────────────────────────────────────────────
              TextFormField(
                controller: _radiusCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Raio permitido (metros)',
                  hintText: '200',
                  prefixIcon: const Icon(Icons.radar_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Informe um raio válido';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Botão: usar GPS atual ─────────────────────────────────
              FilledButton.icon(
                onPressed: ctrl.status == WorkplaceStatus.loading
                    ? null
                    : _saveCurrentLocation,
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Usar minha localização atual'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 12),

              // ── Divisor ───────────────────────────────────────────────
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('ou informe manualmente',
                      style:
                          TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                ),
                const Expanded(child: Divider()),
              ]),

              const SizedBox(height: 12),

              // ── Lat / Lng manuais ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        hintText: '-23.5505',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n < -90 || n > 90) {
                          return 'Latitude inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        hintText: '-46.6333',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n < -180 || n > 180) {
                          return 'Longitude inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: ctrl.status == WorkplaceStatus.loading
                    ? null
                    : _saveManual,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar coordenadas manualmente'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              if (ctrl.status == WorkplaceStatus.loading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}