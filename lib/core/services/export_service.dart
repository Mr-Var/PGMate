import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/daos/billing_dao.dart';
import '../database/daos/reports_dao.dart';
import '../database/enums.dart';
import '../utils/dates.dart';
import '../utils/money.dart';

/// PDF receipts and reports, CSV export and sharing. All offline.
class ExportService {
  pw.ThemeData? _theme;

  static const _ink = PdfColor.fromInt(0xFF0F172A);
  static const _muted = PdfColor.fromInt(0xFF5B6576);
  static const _line = PdfColor.fromInt(0xFFE3E8EF);
  static const _brand = PdfColor.fromInt(0xFF1D4ED8);
  static const _soft = PdfColor.fromInt(0xFFF4F6F9);

  Future<pw.ThemeData> _pdfTheme() async {
    if (_theme != null) return _theme!;
    Future<pw.Font> f(String w) async => pw.Font.ttf(await rootBundle.load('assets/fonts/IBMPlexSans-$w.ttf'));
    return _theme = pw.ThemeData.withFont(base: await f('Regular'), bold: await f('SemiBold'));
  }

  // ---------------------------------------------------------------- Receipt

  Future<Uint8List> receiptPdf(ReceiptData r) async {
    final theme = await _pdfTheme();
    final doc = pw.Document(title: 'Receipt ${r.payment.receiptNumber}', author: r.profile.name, theme: theme);
    final p0 = r.payment;
    final isReversal = p0.kind == PaymentKind.reversal;
    final months = r.lines.map((l) => Dates.monthYear(l.period)).toSet().join(', ');

    pw.Widget kv(String k, String v, {bool strong = false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(k, style: const pw.TextStyle(color: _muted, fontSize: 10)),
          ),
          pw.Expanded(
            child: pw.Text(
              v,
              style: pw.TextStyle(fontSize: strong ? 12 : 10, fontWeight: strong ? pw.FontWeight.bold : null),
            ),
          ),
        ],
      ),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        r.profile.name,
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _ink),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(r.profile.address, style: const pw.TextStyle(fontSize: 9, color: _muted)),
                      pw.Text(
                        '${r.profile.ownerName} · +91 ${r.profile.ownerPhone}',
                        style: const pw.TextStyle(fontSize: 9, color: _muted),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(color: _brand, borderRadius: pw.BorderRadius.circular(6)),
                  child: pw.Text(
                    isReversal ? 'REVERSAL' : 'RENT RECEIPT',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(color: _soft, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    isReversal ? 'Amount reversed' : 'Amount received',
                    style: const pw.TextStyle(fontSize: 9, color: _muted),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    Money.format(p0.amountPaise.abs()),
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _ink),
                  ),
                  pw.Text(_inWords(p0.amountPaise.abs()), style: const pw.TextStyle(fontSize: 9, color: _muted)),
                ],
              ),
            ),
            pw.SizedBox(height: 14),
            kv('Receipt number', p0.receiptNumber, strong: true),
            kv('Payment date', Dates.short(p0.paymentDate)),
            kv('Received from', r.tenant.fullName),
            if (r.roomLabel != null) kv('Room', r.roomLabel!),
            kv('Payment method', p0.method.label),
            if (p0.upiReference != null) kv('UPI reference (UTR)', p0.upiReference!),
            if (months.isNotEmpty) kv('Rent for', months),
            kv('Transaction ID', p0.transactionId),
            pw.SizedBox(height: 10),
            if (r.lines.isNotEmpty) ...[
              pw.Divider(color: _line),
              for (final l in r.lines)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '${Dates.monthYear(l.period)} rent · ${l.invoiceNumber}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Text(Money.format(l.amountPaise), style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
            ],
            pw.Divider(color: _line),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    'Outstanding balance',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Text(
                  Money.format(r.outstandingPaise),
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            if (r.creditPaise > 0)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text('Advance credit', style: const pw.TextStyle(fontSize: 10, color: _muted)),
                    ),
                    pw.Text(Money.format(r.creditPaise), style: const pw.TextStyle(fontSize: 10, color: _muted)),
                  ],
                ),
              ),
            pw.Spacer(),
            pw.Divider(color: _line),
            pw.Text(
              p0.status == PaymentStatus.pendingVerification
                  ? 'UPI payment awaiting owner verification. This is not yet a confirmed receipt.'
                  : 'Computer-generated receipt from ${r.profile.name}. No signature required.',
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }

  static String _inWords(int paise) {
    final rupees = paise ~/ 100;
    final p = paise % 100;
    final w = rupees == 0 ? 'Zero' : _words(rupees);
    return 'Rupees $w${p > 0 ? ' and ${_words(p)} paise' : ''} only';
  }

  static String _words(int n) {
    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    String two(int x) => x < 20 ? ones[x] : '${tens[x ~/ 10]}${x % 10 > 0 ? ' ${ones[x % 10]}' : ''}';
    String three(int x) => x >= 100 ? '${ones[x ~/ 100]} Hundred${x % 100 > 0 ? ' ${two(x % 100)}' : ''}' : two(x);
    final parts = <String>[];
    final crore = n ~/ 10000000, lakh = (n ~/ 100000) % 100, thousand = (n ~/ 1000) % 100, rest = n % 1000;
    if (crore > 0) parts.add('${_words(crore)} Crore');
    if (lakh > 0) parts.add('${two(lakh)} Lakh');
    if (thousand > 0) parts.add('${two(thousand)} Thousand');
    if (rest > 0) parts.add(three(rest));
    return parts.join(' ');
  }

  // ----------------------------------------------------------------- Reports

  Future<Uint8List> reportPdf(ReportTable t, {required String pgName}) async {
    final theme = await _pdfTheme();
    final doc = pw.Document(title: t.title, author: pgName, theme: theme);
    final wide = t.columns.length > 5;
    doc.addPage(
      pw.MultiPage(
        pageFormat: wide ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (c) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      t.title,
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _ink),
                    ),
                    pw.Text('$pgName · ${t.subtitle}', style: const pw.TextStyle(fontSize: 9, color: _muted)),
                  ],
                ),
              ),
              pw.Text('Page ${c.pageNumber}/${c.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: _muted)),
            ],
          ),
        ),
        footer: (c) => pw.Text(
          'Generated ${Dates.short(DateTime.now())} by PG Manager',
          style: const pw.TextStyle(fontSize: 8, color: _muted),
        ),
        build: (_) => [
          if (t.summary.isNotEmpty)
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in t.summary)
                  pw.Container(
                    width: 150,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(color: _soft, borderRadius: pw.BorderRadius.circular(6)),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(s.$1, style: const pw.TextStyle(fontSize: 8, color: _muted)),
                        pw.SizedBox(height: 2),
                        pw.Text(s.$2, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
          pw.SizedBox(height: 14),
          if (t.rows.isEmpty)
            pw.Text('No records for this period.', style: const pw.TextStyle(color: _muted))
          else
            pw.TableHelper.fromTextArray(
              headers: [for (final c in t.columns) c.label],
              data: t.rows,
              headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: _brand),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              oddRowDecoration: const pw.BoxDecoration(color: _soft),
              border: null,
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              columnWidths: {
                for (var i = 0; i < t.columns.length; i++) i: pw.FlexColumnWidth(t.columns[i].flex.toDouble()),
              },
              cellAlignments: {
                for (var i = 0; i < t.columns.length; i++)
                  i: t.columns[i].align == ColumnAlign.right ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
              },
            ),
          if (t.footer != null) ...[
            pw.SizedBox(height: 10),
            for (final f in t.footer!) pw.Text(f, style: const pw.TextStyle(fontSize: 9, color: _muted)),
          ],
        ],
      ),
    );
    return doc.save();
  }

  /// RFC 4180 CSV with a UTF-8 BOM so Excel shows ₹ correctly.
  static String toCsv(ReportTable t) {
    String esc(String v) => RegExp(r'[",\n\r]').hasMatch(v) ? '"${v.replaceAll('"', '""')}"' : v;
    final b = StringBuffer('﻿');
    b.writeln([t.title, t.subtitle].map(esc).join(','));
    for (final s in t.summary) {
      b.writeln([s.$1, s.$2].map(esc).join(','));
    }
    b.writeln();
    b.writeln(t.columns.map((c) => esc(c.label)).join(','));
    for (final r in t.rows) {
      b.writeln(r.map(esc).join(','));
    }
    return b.toString();
  }

  // ----------------------------------------------------------------- Sharing

  Future<File> writeTemp(String fileName, List<int> bytes) async {
    final dir = Directory(p.join((await getTemporaryDirectory()).path, 'exports'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final f = File(p.join(dir.path, fileName));
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  Future<void> shareFile(File file, {String? text, required String mime}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mime)],
        text: text,
      ),
    );
  }

  Future<void> shareCsv(ReportTable t, String fileName) async {
    final f = await writeTemp(fileName, utf8.encode(toCsv(t)));
    await shareFile(f, mime: 'text/csv', text: t.title);
  }

  Future<void> shareText(String text) => SharePlus.instance.share(ShareParams(text: text));

  /// Opens WhatsApp with a message, optionally to a specific number.
  Future<bool> whatsapp(String text, {String? phone}) {
    final to = phone == null
        ? ''
        : '91${phone.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^91(?=\d{10}$)'), '')}';
    return launchUrl(
      Uri.parse('https://wa.me/$to?text=${Uri.encodeComponent(text)}'),
      mode: LaunchMode.externalApplication,
    );
  }

  /// UPI intent for the owner's UPI ID, pre-filled with amount and note.
  static Uri upiUri({
    required String upiId,
    required String payeeName,
    required int amountPaise,
    required String note,
  }) {
    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': upiId,
        'pn': payeeName,
        'am': (amountPaise / 100).toStringAsFixed(2),
        'cu': 'INR',
        'tn': note,
      },
    );
  }
}
