import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../localization/app_localizations.dart';

class AddCupDialog extends StatefulWidget {
  const AddCupDialog({Key? key}) : super(key: key);

  @override
  State<AddCupDialog> createState() => _AddCupDialogState();
}

class _AddCupDialogState extends State<AddCupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ouncesController = TextEditingController();
  final _mlController = TextEditingController();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _thresholdController = TextEditingController(text: '20');

  @override
  void dispose() {
    _ouncesController.dispose();
    _mlController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context, listen: false);
    final isRtl = context.isRtl;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      title: Text(
        context.translate('add_custom_size'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _ouncesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: context.translate('ounces'),
                  prefixIcon: const Icon(Icons.square_foot),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _mlController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: context.translate('milliliters'),
                  prefixIcon: const Icon(Icons.local_drink),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _nameArController,
                decoration: InputDecoration(
                  labelText: context.translate('name_ar'),
                  prefixIcon: const Icon(Icons.translate),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _nameEnController,
                decoration: InputDecoration(
                  labelText: context.translate('name_en'),
                  prefixIcon: const Icon(Icons.language),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _thresholdController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: context.translate('threshold'),
                  prefixIcon: const Icon(Icons.warning_amber_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.translate('cancel')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final oz = double.tryParse(_ouncesController.text) ?? 0.0;
              final ml = double.tryParse(_mlController.text) ?? 0.0;
              final threshold = double.tryParse(_thresholdController.text) ?? 20.0;

              await provider.addCustomCupPreset(
                ounces: oz,
                milliliters: ml,
                nameAr: _nameArController.text,
                nameEn: _nameEnController.text,
                lowStockThreshold: threshold,
              );

              if (mounted) Navigator.pop(context);
            }
          },
          child: Text(context.translate('add_custom_size')),
        ),
      ],
    );
  }
}
