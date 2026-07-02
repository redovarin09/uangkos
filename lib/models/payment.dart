import 'package:hive_ce/hive.dart';

class Payment extends HiveObject {
  double amount;        // Nominal pembayaran (Rupiah)
  DateTime paymentDate; // Tanggal bayar aktual
  DateTime periodMonth; // Periode: selalu hari pertama bulan (yyyy-MM-01)
  String? note;         // Catatan opsional

  Payment({
    required this.amount,
    required this.paymentDate,
    required this.periodMonth,
    this.note,
  });

  /// Apakah payment ini untuk bulan & tahun tertentu?
  bool isForMonth(int month, int year) =>
      periodMonth.month == month && periodMonth.year == year;
}

// ─── Manual TypeAdapter ──────────────────────────────────────────
class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final int typeId = 0;

  @override
  Payment read(BinaryReader reader) {
    return Payment(
      amount:       reader.readDouble(),
      paymentDate:  DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      periodMonth:  DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      note:         reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.paymentDate.millisecondsSinceEpoch);
    writer.writeInt(obj.periodMonth.millisecondsSinceEpoch);
    writer.writeBool(obj.note != null);
    if (obj.note != null) writer.writeString(obj.note!);
  }
}
