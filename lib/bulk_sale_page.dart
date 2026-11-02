import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class BulkSalePage extends StatefulWidget {
  const BulkSalePage({super.key});

  @override
  State<BulkSalePage> createState() => _BulkSalePageState();
}

class _BulkSalePageState extends State<BulkSalePage> {
  final TextEditingController startController =
  TextEditingController();

  final TextEditingController endController =
  TextEditingController();

  final TextEditingController buyerController =
  TextEditingController();

  final TextEditingController dateController =
  TextEditingController();

  bool isLoading = false;

  int totalCount = 0;
  int processedCount = 0;
  int successCount = 0;
  int duplicateCount = 0;
  int notFoundCount = 0;
  int errorCount = 0;

  List<String> results = [];

  static const String baseUrl =
      "https://mohammadreza-karimi.ir/api/";

  // تبدیل نام جدول به نام محصول
  String getProductName(String table) {
    switch (table) {
      case "numbers_ab1":
        return "AB1";
      case "numbers_db1":
        return "DB1";
      case "numbers_db1s":
        return "DB1-S";
      case "numbers_dr1":
        return "DR1";
      case "numbers_dr1s":
        return "DR1-S";
      default:
        return "-";
    }
  }

  // تولید سریال‌های متوالی با حفظ پیشوند و صفرهای ابتدایی
  List<String> generateSerials(String start, String end) {
    final startMatch = RegExp(r'^(.*?)(\d+)$').firstMatch(start);
    final endMatch = RegExp(r'^(.*?)(\d+)$').firstMatch(end);

    if (startMatch == null || endMatch == null) {
      throw Exception("فرمت سریال باید به عدد ختم شود");
    }

    final startPrefix = startMatch.group(1)!;
    final endPrefix = endMatch.group(1)!;

    if (startPrefix != endPrefix) {
      throw Exception("پیشوند سریال شروع و پایان یکسان نیست");
    }

    final startNumber = int.parse(startMatch.group(2)!);
    final endNumber = int.parse(endMatch.group(2)!);

    if (endNumber < startNumber) {
      throw Exception("سریال پایان باید بزرگ‌تر از سریال شروع باشد");
    }

    final width = [
      startMatch.group(2)!.length,
      endMatch.group(2)!.length
    ].reduce((a, b) => a > b ? a : b);

    final count = endNumber - startNumber + 1;

    if (count > 1000) {
      throw Exception("حداکثر تعداد سریال در هر عملیات ۱۰۰۰ عدد است");
    }

    return List.generate(
      count,
          (index) =>
      "$startPrefix${(startNumber + index).toString().padLeft(width, '0')}",
    );
  }

  Future<void> pickDate() async {
    Jalali? pickedDate = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1400, 1, 1),
      lastDate: Jalali(1500, 12, 29),
      locale: const Locale("fa", "IR"),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text =
        "${pickedDate.year}-"
            "${pickedDate.month.toString().padLeft(2, '0')}-"
            "${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // خواندن اطلاعات QC و محصول هر سریال
  Future<Map<String, dynamic>?> searchSerial(String serial) async {
    final url = Uri.parse(
      "${baseUrl}search_serial.php?serial=${Uri.encodeQueryComponent(serial)}",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("خطای ارتباط با سرور");
    }

    final data = jsonDecode(response.body);

    if (data["status"] == "ok") {
      return data;
    }

    return null;
  }

  // ثبت اطلاعات فروش هر سریال
  Future<String> insertSale({
    required String serial,
    required String product,
    required String producer,
    required String qc,
    required String buyer,
    required String date,
  }) async {
    final url = Uri.parse(
      "${baseUrl}insert_sale2.php",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "serial": serial,
        "product": product,
        "producer": producer,
        "qc_operator": qc,
        "buyer_name": buyer,
        "patient_name": "",
        "uid": "",
        "exit_date": date,
        "guarantee_date": "",
        "description": "",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("خطای ثبت در سرور");
    }

    final data = jsonDecode(response.body);

    return data["status"]?.toString() ?? "error";
  }

  Future<void> startBulkRegistration() async {
    final start = startController.text.trim();
    final end = endController.text.trim();
    final buyer = buyerController.text.trim();
    final date = dateController.text.trim();

    if (start.isEmpty ||
        end.isEmpty ||
        // buyer.isEmpty ||
        date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تمام فیلدها را تکمیل کنید"),
        ),
      );
      return;
    }

    List<String> serials;

    try {
      serials = generateSerials(start, end);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأیید ثبت گروهی"),
        content: Text(
          "تعداد ${serials.length} سریال برای خریدار $buyer ثبت شود؟",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("لغو"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("شروع ثبت"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      isLoading = true;

      totalCount = serials.length;
      processedCount = 0;
      successCount = 0;
      duplicateCount = 0;
      notFoundCount = 0;
      errorCount = 0;

      results.clear();
    });

    for (final serial in serials) {
      try {
        // مرحله اول: جستجوی سریال
        final searchData = await searchSerial(serial);

        if (searchData == null) {
          notFoundCount++;
          results.add("❌ $serial : سریال پیدا نشد");
        } else {
          final table = searchData["table"]?.toString() ?? "";

          final product = getProductName(table);
          final producer =
              searchData["producer"]?.toString() ?? "";
          final qc =
              searchData["qc_operator"]?.toString() ?? "";

          if (product == "-") {
            errorCount++;
            results.add("⚠️ $serial : جدول محصول نامعتبر است");
          } else {
            // مرحله دوم: ثبت فروش
            final status = await insertSale(
              serial: serial,
              product: product,
              producer: producer,
              qc: qc,
              buyer: buyer,
              date: date,
            );

            if (status == "ok") {
              successCount++;
              results.add("✅ $serial : با موفقیت ثبت شد");
            } else if (status == "duplicate") {
              duplicateCount++;
              results.add("⚠️ $serial : قبلاً ثبت شده است");
            } else {
              errorCount++;
              results.add("❌ $serial : خطا در ثبت");
            }
          }
        }
      } catch (e) {
        errorCount++;
        results.add("❌ $serial : خطای ارتباط یا پردازش");
      }

      if (!mounted) return;

      setState(() {
        processedCount++;
      });
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("عملیات ثبت گروهی به پایان رسید"),
      ),
    );
  }

  @override
  void dispose() {
    startController.dispose();
    endController.dispose();
    buyerController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Widget buildInput({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon ?? Icons.edit),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),
      appBar: AppBar(
        title: const Text("ثبت گروهی فروش"),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
        foregroundColor: Colors.black,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width > 700
                  ? 800
                  : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 15),

                  const Text(
                    "بازه شماره سریال",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  buildInput(
                    label: "سریال شروع",
                    controller: startController,
                    icon: Icons.first_page,
                  ),

                  const SizedBox(height: 20),

                  buildInput(
                    label: "سریال پایان",
                    controller: endController,
                    icon: Icons.last_page,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "اطلاعات مشترک فروش",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // buildInput(
                  //   label: "نام خریدار",
                  //   controller: buyerController,
                  //   icon: Icons.person,
                  // ),

                  const SizedBox(height: 20),

                  buildInput(
                    label: "تاریخ خروج",
                    controller: dateController,
                    icon: Icons.calendar_month,
                    onTap: pickDate,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                      isLoading ? null : startBulkRegistration,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        " ثبت گروهی",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[100],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  if (totalCount > 0) ...[
                    const SizedBox(height: 30),

                    const Text(
                      "وضعیت عملیات",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    LinearProgressIndicator(
                      value: totalCount == 0
                          ? 0
                          : processedCount / totalCount,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "$processedCount از $totalCount سریال پردازش شده",
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _statusCard("موفق", successCount, Colors.green),
                        _statusCard("تکراری", duplicateCount, Colors.orange),
                        _statusCard("پیدا نشد", notFoundCount, Colors.red),
                        _statusCard("خطا", errorCount, Colors.grey),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "جزئیات سریال‌ها",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: results.map((item) {
                          return ListTile(
                            dense: true,
                            title: Text(
                              item,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusCard(String title, int count, Color color) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }
}
