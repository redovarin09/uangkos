import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uang_kos/models/payment.dart';

class DatabaseService {
  static const String _paymentBox = 'payments';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PaymentAdapter());
    await Hive.openBox<Payment>(_paymentBox);
  }

  static Box<Payment> get paymentBox => Hive.box<Payment>(_paymentBox);
}
