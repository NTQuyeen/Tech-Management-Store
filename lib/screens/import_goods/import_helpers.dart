import 'dart:io';
import 'package:intl/intl.dart';
import 'import_models.dart';

Future<File> saveImportReceiptTxt({
  required String receiptCode,
  required DateTime receiptDate,
  required PaymentStatus paymentStatus,
  required String supplierName,
  required String supplierPhone,
  required String supplierEmail,
  required String supplierAddress,
  required List<ImportLine> lines,
  String? createdBy,
}) async {
  final now = DateTime.now();
  final ts = DateFormat('yyyyMMdd_HHmmss').format(now);

  final sb = StringBuffer();
  sb.writeln('========== PHIEU NHAP HANG ==========');
  sb.writeln('Ma phieu: $receiptCode');
  sb.writeln('Ngay nhap: ${DateFormat('dd/MM/yyyy').format(receiptDate)}');
  sb.writeln('Trang thai thanh toan: ${paymentStatus.label}');
  sb.writeln('Tao luc: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(now)}');
  if (createdBy != null && createdBy.isNotEmpty) {
    sb.writeln('Nguoi tao: $createdBy');
  }

  sb.writeln('\n--- NHA CUNG CAP ---');
  sb.writeln('Ten: $supplierName');
  sb.writeln('SDT: $supplierPhone');
  if (supplierEmail.trim().isNotEmpty) sb.writeln('Email: $supplierEmail');
  if (supplierAddress.trim().isNotEmpty)
    sb.writeln('Dia chi: $supplierAddress');

  sb.writeln('\n--- CHI TIET HANG NHAP ---');
  sb.writeln('STT | MaSP | TenSP | SL | GiaNhap | ThanhTien');

  int i = 1;
  double total = 0;

  for (final line in lines) {
    final lineTotal = line.lineTotal;
    total += lineTotal;

    sb.writeln(
      '$i | ${line.product.code} | ${line.product.name} | '
      '${line.quantity} | ${formatMoney(line.costPrice)} | ${formatMoney(lineTotal)}',
    );
    i++;
  }

  sb.writeln('\nTONG TIEN NHAP: ${formatMoney(total)}');
  sb.writeln('========== END ==========');

  // ✅ Lưu vào thư mục dự án (working directory) / export_phieu_nhap
  final exportDir = Directory('${Directory.current.path}/export_phieu_nhap');
  if (!await exportDir.exists()) {
    await exportDir.create(recursive: true);
  }

  // ✅ làm tên file an toàn
  final safeReceipt = receiptCode.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
  final file = File('${exportDir.path}/phieu_nhap_${safeReceipt}_$ts.txt');

  return file.writeAsString(sb.toString(), flush: true);
}

String formatMoney(double x) {
  final n = x.round().toString();
  final withDots = n.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return "$withDots đ";
}

String formatDateVN(DateTime d) =>
    "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
