import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uang_kos/core/constants/app_colors.dart';
import 'package:uang_kos/core/constants/app_strings.dart';
import 'package:uang_kos/core/utils/date_formatter.dart';
import 'package:uang_kos/models/payment.dart';
import 'package:uang_kos/providers/payment_provider.dart';

class PaymentFormSheet extends ConsumerStatefulWidget {
  final Payment? existing;
  const PaymentFormSheet({super.key, this.existing});

  @override
  ConsumerState<PaymentFormSheet> createState() => _PaymentFormSheetState();
}

class _PaymentFormSheetState extends ConsumerState<PaymentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late DateTime _paymentDate;
  late DateTime _periodMonth;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final e   = widget.existing;
    _amountCtrl = TextEditingController(
      text: e != null ? e.amount.toInt().toString() : '',
    );
    _noteCtrl   = TextEditingController(text: e?.note ?? '');
    _paymentDate = e?.paymentDate ?? now;
    _periodMonth = e?.periodMonth ?? DateTime(now.year, now.month, 1);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _pickPeriodMonth() async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (_) => _MonthPickerDialog(initial: _periodMonth),
    );
    if (result != null) setState(() => _periodMonth = result);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final amount = double.parse(_amountCtrl.text);
    final note   = _noteCtrl.text.trim().isEmpty
        ? null
        : _noteCtrl.text.trim();

    try {
      if (_isEditing) {
        final p    = widget.existing!;
        p.amount   = amount;
        p.paymentDate = _paymentDate;
        p.periodMonth = DateTime(_periodMonth.year, _periodMonth.month, 1);
        p.note     = note;
        await ref.read(paymentProvider.notifier).update(p);
      } else {
        await ref.read(paymentProvider.notifier).add(Payment(
          amount:      amount,
          paymentDate: _paymentDate,
          periodMonth: DateTime(_periodMonth.year, _periodMonth.month, 1),
          note:        note,
        ));
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing
              ? AppStrings.msgPembayaranDiEdit
              : AppStrings.msgPembayaranDisimpan),
        ));
      }
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  Widget _dateTile({required String value, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt     = Theme.of(context).textTheme;
    final cs     = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              _isEditing
                  ? AppStrings.labelEdit
                  : AppStrings.labelCatatBayar,
              style: tt.titleLarge,
            ),
            const SizedBox(height: 20),

            // ── Nominal ──────────────────────────
            Text(AppStrings.labelNominal, style: tt.labelMedium),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(prefixText: 'Rp '),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nominal wajib diisi';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Masukkan nominal yang valid';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Periode bulan ─────────────────────
            Text(AppStrings.labelPeriode, style: tt.labelMedium),
            const SizedBox(height: 6),
            _dateTile(
              value: DateFormatter.monthYear(_periodMonth),
              onTap: _pickPeriodMonth,
            ),
            const SizedBox(height: 14),

            // ── Tanggal bayar ─────────────────────
            Text(AppStrings.labelTanggalBayar, style: tt.labelMedium),
            const SizedBox(height: 6),
            _dateTile(
              value: DateFormatter.dayMonthYear(_paymentDate),
              onTap: _pickPaymentDate,
            ),
            const SizedBox(height: 14),

            // ── Catatan ───────────────────────────
            Text(AppStrings.labelCatatan, style: tt.labelMedium),
            const SizedBox(height: 6),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'contoh: Termasuk biaya wifi',
              ),
            ),
            const SizedBox(height: 20),

            // ── Simpan ────────────────────────────
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(AppStrings.labelSimpan),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Month Picker Dialog ──────────────────────────────────────────
class _MonthPickerDialog extends StatefulWidget {
  final DateTime initial;
  const _MonthPickerDialog({required this.initial});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;
  late int _month;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr',
    'Mei', 'Jun', 'Jul', 'Agu',
    'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void initState() {
    super.initState();
    _year  = widget.initial.year;
    _month = widget.initial.month;
  }

  @override
  Widget build(BuildContext context) {
    final tt  = Theme.of(context).textTheme;
    final now = DateTime.now();

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => setState(() => _year--),
          ),
          Text('$_year', style: tt.titleMedium),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: _year < now.year + 1
                ? () => setState(() => _year++)
                : null,
          ),
        ],
      ),
      content: SizedBox(
        width: 280,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.4,
          ),
          itemCount: 12,
          itemBuilder: (_, i) {
            final selected = (i + 1) == _month;
            return GestureDetector(
              onTap: () => setState(() => _month = i + 1),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _months[i],
                  style: tt.labelMedium?.copyWith(
                    color: selected ? Colors.white : null,
                    fontWeight:
                        selected ? FontWeight.w700 : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.labelBatal),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            DateTime(_year, _month, 1),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(80, 40),
          ),
          child: const Text(AppStrings.labelSimpan),
        ),
      ],
    );
  }
}
