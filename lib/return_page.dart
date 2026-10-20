import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReturnPage extends StatefulWidget {
const ReturnPage({super.key});

@override
State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
final TextEditingController serialController =
TextEditingController();

bool isLoading = false;
bool isFound = false;
bool isReturned = false;

Map<String, dynamic>? sale;

Future<void> searchSale() async {
final serial = serialController.text.trim();

if (serial.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("شماره سریال را وارد کنید"),
),
);
return;
}

FocusScope.of(context).unfocus();

setState(() {
isLoading = true;
isFound = false;
isReturned = false;
sale = null;
});

try {
final url = Uri.parse(
"https://mohammadreza-karimi.ir/api/search_sale.php"
"?serial=${Uri.encodeComponent(serial)}",
);

final response = await http.get(url);

// debugPrint("SEARCH STATUS: ${response.statusCode}");
// debugPrint("SEARCH RESPONSE: ${response.body}");

if (response.statusCode != 200) {
throw Exception("خطای سرور: ${response.statusCode}");
}

final data = jsonDecode(response.body);

if (data["status"] != "ok") {
throw Exception(data["message"] ?? "سریال پیدا نشد");
}

final item = Map<String, dynamic>.from(data["data"]);

if (!mounted) return;

setState(() {
sale = item;
isFound = true;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("اطلاعات پیدا شد"),
),
);
} catch (e) {
debugPrint("SEARCH ERROR: $e");

if (!mounted) return;

setState(() {
isFound = false;
sale = null;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("خطا در جستجو: $e"),
),
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

Future<void> registerReturn() async {
if (!isFound || sale == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("ابتدا شماره سریال را جستجو کنید"),
),
);
return;
}

if (isReturned) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("این سمعک قبلاً مرجوع شده است"),
),
);
return;
}

final serial =
sale!["serial"]?.toString() ?? serialController.text.trim();

final buyer = sale!["buyer_name"]?.toString().trim() ?? "";

if (serial.isEmpty || buyer.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("شماره سریال یا نام خریدار معتبر نیست"),
),
);
return;
}

setState(() {
isLoading = true;
});

try {
 var url = Uri.parse(
"https://mohammadreza-karimi.ir/api/hearing_aid_return.php",
);

var response = await http.post(
url,
headers: {
  "Content-Type":
  "application/x-www-form-urlencoded",
},
body: {
"serial": serial,
"buyer_name": buyer,
},
);

debugPrint("REGISTER STATUS: ${response.statusCode}");
debugPrint("REGISTER RESPONSE: ${response.body}");

var data = jsonDecode(response.body);

if (!mounted) return;

if (data["status"] == "ok") {
setState(() {
// isReturned = true;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
 "با موفقیت ارجاع داده شد",
),
),
);
} else {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
data["message"]?.toString() ?? "ثبت مرجوعی ناموفق بود",
),
),
);
}
} catch (e) {
debugPrint("REGISTER ERROR: $e");

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("خطا در ثبت مرجوعی: $e"),
),
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

Future<void> deleteSale2() async {

  String serial =
  serialController.text.trim();

  if (serial.isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("شماره سریال را وارد کنید"),
      ),
    );

    return;
  }

  // Confirmation
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (context) {

      return AlertDialog(

        title: const Text("حذف سریال"),

        content: Text(
          "آیا مطمئن هستید که می‌خواهید سریال\n$serial\nرا حذف کنید؟",
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("لغو"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("حذف"),
          ),

        ],
      );
    },
  );

  if (confirm != true) {
    return;
  }

  try {

    var url = Uri.parse(
      "https://mohammadreza-karimi.ir/api/delete_sale.php",
    );

    var response = await http.post(

      url,

      headers: {
        "Content-Type":
        "application/x-www-form-urlencoded",
      },

      body: {
        "serial": serial,
      },
    );

    print("DELETE STATUS: ${response.statusCode}");
    print("DELETE RESPONSE: ${response.body}");

    var data = jsonDecode(response.body);

    if (data["status"] == "ok") {

      // Clear fields
      serialController.clear();


      setState(() {

      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("با موفقیت حذف شد"),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data["message"] ?? "Delete failed",
          ),
        ),
      );
    }

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
      ),
    );
  }
}


Future<void> exportCSV2() async {

  try {

    String url =
        "https://mohammadreza-karimi.ir/api/read_return.php";

    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData["status"] != "ok") {
      throw Exception("Server error");
    }

    List data = jsonData["data"];

    StringBuffer csv = StringBuffer();
// UTF-8 BOM
    csv.write('\uFEFF');

    csv.writeln(
        "Serial,Buyer");

    for (var item in data) {

      csv.writeln(
          "${item["serial"]},"
              "${item["buyer_name"]},"
      );
    }

    final bytes = utf8.encode(csv.toString());

    final blob = html.Blob([bytes]);

    final url2 =
    html.Url.createObjectUrlFromBlob(blob);

    final anchor =
    html.AnchorElement(href: url2)
      ..setAttribute(
          "download",
          "return_report.csv")
      ..click();

    html.Url.revokeObjectUrl(url2);

  } catch (e) {

    print("Export error: $e");
  }
}

Widget buildInfoRow(
IconData icon,
String title,
dynamic value,
Color iconColor,
) {
return Padding(
padding: const EdgeInsets.only(bottom: 12),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
icon,
size: 21,
color: iconColor,
),
const SizedBox(width: 10),
Text(
"$title: ",
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
Expanded(
child: Text(
value?.toString() ?? "-",
),
),
],
),
);
}

@override
void dispose() {
serialController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("مرجوعی براساس شماره سریال"),
centerTitle: true,
backgroundColor: Colors.blue[200],
foregroundColor: Colors.black,
),
body: Directionality(
textDirection: TextDirection.rtl,
child: SingleChildScrollView(
child: Padding(
padding: const EdgeInsets.all(20),
child: Align(
alignment: Alignment.topCenter,
child: SizedBox(
width: MediaQuery.of(context).size.width > 700
? 800
    : double.infinity,
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
const SizedBox(height: 10),
TextField(
controller: serialController,
textDirection: TextDirection.ltr,
textAlign: TextAlign.left,
decoration: InputDecoration(
labelText: "شماره سریال را وارد نمایید",
prefixIcon: const Icon(
Icons.confirmation_number,
color: Colors.blue,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(15),
),
),
onSubmitted: (_) => searchSale(),
),
const SizedBox(height: 20),
SizedBox(
height: 45,
child: ElevatedButton.icon(
onPressed: isLoading ? null : searchSale,
icon: const Icon(Icons.search),
label: isLoading
? const SizedBox(
width: 22,
height: 22,
child: CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
    : const Text(
"جستجو",
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
const SizedBox(height: 30),
if (isFound && sale != null) ...[
Card(
elevation: 3,
margin: const EdgeInsets.only(bottom: 15),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
child: Padding(
padding: const EdgeInsets.all(15),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
const Icon(
Icons.confirmation_number,
color: Colors.red,
),
const SizedBox(width: 8),
Expanded(
child: SelectableText(
"شماره سریال: ${sale!["serial"] ?? serialController.text}",
style: const TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
),
),
],
),
const Divider(height: 25),
buildInfoRow(
Icons.person_outline,
"نام خریدار",
sale!["buyer_name"],
Colors.green,
),
],
),
),
),
if (isReturned)
Container(
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: Colors.orange.shade50,
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: Colors.orange.shade300,
),
),
child: const Row(
children: [
Icon(
Icons.warning_amber,
color: Colors.deepOrange,
),
SizedBox(width: 8),
Expanded(
child: Text(
"این سمعک قبلاً مرجوع شده است.",
),
),
],
),
)
else

SizedBox(
height: 48,
child: ElevatedButton.icon(
onPressed:
isLoading ? null : registerReturn,
icon: const Icon(
Icons.assignment_return,
color: Colors.white,
),
label: const Text(
"ثبت مرجوعی",
style: TextStyle(fontSize: 16),
),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red[700],
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
),
),
  const Divider(height: 25),
  SizedBox(
    height: 48,
    child: ElevatedButton.icon(
      onPressed:
      isLoading ? null : deleteSale2,
      icon: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
      label: const Text(
        "حذف داده",
        style: TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),
  const Divider(height: 25),
  SizedBox(
    height: 48,
    child: ElevatedButton.icon(
      onPressed:
      isLoading ? null : exportCSV2,
      icon: const Icon(
        Icons.download  ,
        color: Colors.white,
      ),
      label: const Text(
        "اکسل خروجی",
        style: TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),
],
],
),
),
),
),
),
),
);
}
}
