
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'buyer_search_page.dart';
import 'edit_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

void main() {
runApp(MyApp());
}

class MyApp extends StatelessWidget {

@override
Widget build(BuildContext context) {

return MaterialApp(

debugShowCheckedModeBanner: false,

title: 'Serial Search',
  supportedLocales: const [
    Locale("fa", "IR"),
    Locale("en", "US"),
  ],
  localizationsDelegates: const [
    PersianMaterialLocalizations.delegate,
    PersianCupertinoLocalizations.delegate,

    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
theme: ThemeData(
useMaterial3: true,
),

home: SearchPage(),
);
}
}

class SearchPage extends StatefulWidget {

@override
State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

List<String> buyerNames = [];

TextEditingController serialController =
TextEditingController();

TextEditingController buyerController =
TextEditingController();

TextEditingController patietController =
TextEditingController();

TextEditingController UIDController =
TextEditingController();

TextEditingController exitDateController =
TextEditingController();

TextEditingController guaDateController =
TextEditingController();

TextEditingController descriptionController =
TextEditingController();

@override
void initState() {
  super.initState();

  loadBuyerNames();
}

bool isLoading = false;

String product = "-";
String producer = "-";
String qc = "-";

void loadBuyerNames() {

  String? saved =
  html.window.localStorage["buyer_names"];

  if (saved != null && saved.isNotEmpty) {

    setState(() {

      buyerNames =
      List<String>.from(jsonDecode(saved));

    });
  }
}

void saveBuyerName(String name) {

  name = name.trim();

  if (name.isEmpty) return;

  if (!buyerNames.contains(name)) {

    buyerNames.add(name);

    html.window.localStorage["buyer_names"] =
        jsonEncode(buyerNames);
  }
}

Future<void> searchSerial() async {

if (serialController.text.isEmpty) {

ScaffoldMessenger.of(context).showSnackBar(

SnackBar(
content: Text("شماره سریال را وارد کنید"),
),
);

return;
}

setState(() {
isLoading = true;
});

try {

var url = Uri.parse(
"https://mohammadreza-karimi.ir/api/search_serial.php?serial=${serialController.text}",
);

var response = await http.get(url);

var data = json.decode(response.body);

if (data["status"] == "ok") {

String table = data["table"];

switch (table) {

case "numbers_ab1":
table = "AB1";
break;

case "numbers_db1":
table = "DB1";
break;

case "numbers_db1s":
table = "DB1-S";
break;

case "numbers_dr1":
table = "DR1";
break;

case "numbers_dr1s":
table = "DR1-S";
break;
}

setState(() {

product = table;

producer = data["producer"];

qc = data["qc_operator"];
});

} else {

setState(() {

product = "-";
producer = "-";
qc = "-";
});

ScaffoldMessenger.of(context).showSnackBar(

SnackBar(
content: Text("سریال پیدا نشد"),
),
);
}

} catch (e) {

ScaffoldMessenger.of(context).showSnackBar(

SnackBar(
content: Text("خطا : $e"),
),
);
}

setState(() {
isLoading = false;
});
}
Future<void> deleteSale() async {

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
      buyerController.clear();
      patietController.clear();
      UIDController.clear();
      exitDateController.clear();
      guaDateController.clear();
      descriptionController.clear();

      setState(() {

        product = "-";
        producer = "-";
        qc = "-";

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
Future<void> saveSale() async {

try {

String serial =
serialController.text.trim();

String buyer =
buyerController.text.trim();

String patiet =
patietController.text.trim();

String uid =
UIDController.text.trim();

String date =
exitDateController.text.trim();

String gua =
guaDateController.text.trim();

String description =
descriptionController.text.trim();

var url = Uri.parse(
"https://mohammadreza-karimi.ir/api/insert_sale2.php",
);

var response = await http.post(

url,

headers: {

"Content-Type":
"application/x-www-form-urlencoded",
},

body: {

"serial": serial,

"product": product,

"producer": producer,

"qc_operator": qc,

"buyer_name": buyer,

"patient_name": patiet,

"uid": uid,

"exit_date": date,

"guarantee_date": gua,

"description": description,
},
);
// print("STATUS: ${response.statusCode}");
// print("BODY: ${response.body}");
var data =
jsonDecode(response.body);

if (data["status"] == "ok") {
  saveBuyerName(buyer);
buyerController.clear();
patietController.clear();
UIDController.clear();
exitDateController.clear();
guaDateController.clear();
serialController.clear();
descriptionController.clear();
setState(() {
  product = "-";
  producer = "-";
  qc = "-";
});
ScaffoldMessenger.of(context).showSnackBar(

SnackBar(
content: Text("با موفقیت ذخیره شد"),
),
);

} else {
  buyerController.clear();
  patietController.clear();
  UIDController.clear();
  exitDateController.clear();
  guaDateController.clear();
  descriptionController.clear();
  setState(() {
    product = "-";
    producer = "-";
    qc = "-";
  });
ScaffoldMessenger.of(context).showSnackBar(

SnackBar(
content: Text(data["message"]),
),
);
}

} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(

SnackBar(
content: Text("Error : $e"),
),
);
}
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

      exitDateController.text =
      "${pickedDate.year}-"
          "${pickedDate.month.toString().padLeft(2, '0')}-"
          "${pickedDate.day.toString().padLeft(2, '0')}";

    });

  }
}

Future<void> pickDate2() async {

  Jalali? pickedDate = await showPersianDatePicker(

    context: context,

    initialDate: Jalali.now(),

    firstDate: Jalali(1400, 1, 1),

    lastDate: Jalali(1500, 12, 29),
    locale: const Locale("fa", "IR"),
  );

  if (pickedDate != null) {

    setState(() {

      guaDateController.text =
      "${pickedDate.year}-"
          "${pickedDate.month.toString().padLeft(2, '0')}-"
          "${pickedDate.day.toString().padLeft(2, '0')}";

    });

  }
}

Future<void> exportCSV() async {

try {

String url =
"https://mohammadreza-karimi.ir/api/read_sale.php";

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
"Serial,Product,Producer,QC Operator,Buyer,UID,Exit Date,Guarantee Date,Description");

for (var item in data) {

csv.writeln(
"${item["serial"]},"
"${item["product"]},"
"${item["producer"]},"
"${item["qc_operator"]},"
"${item["buyer_name"]},"
"${item["uid"]},"
"${item["exit_date"]},"
"${item["guarantee_date"]},"
"${item["description"]}"
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
"sales_report.csv")
..click();

html.Url.revokeObjectUrl(url2);

} catch (e) {

print("Export error: $e");
}
}

@override
Widget build(BuildContext context) {

return Scaffold(

backgroundColor: const Color(0xfff4f6fb),

appBar: AppBar(

title: const Text("Search Page"),

centerTitle: true,

backgroundColor: Colors.blue[200],

foregroundColor: Colors.black,
),

body: Directionality(
  textDirection: TextDirection.rtl,
child: SingleChildScrollView(
child: Padding(padding: const EdgeInsets.all(20),
child: Align(
  alignment: Alignment.topCenter,
  child: Container(
  width:
  MediaQuery.of(context).size.width > 700
  ? 800
      : double.infinity,


child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
children: [

const SizedBox(height: 10),

TextField(

controller: serialController,

decoration: InputDecoration(

labelText: "شماره سریال",

labelStyle: const TextStyle(
fontSize: 16,
color: Colors.black,
),

prefixIcon: const Icon(
Icons.search,
color: Colors.red,
),

border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(15),
),
),
),

const SizedBox(height: 30),

SizedBox(

width: double.infinity,

height: 45,

child: ElevatedButton(

onPressed:
isLoading
? null
    : searchSerial,

style: ElevatedButton.styleFrom(

backgroundColor:
Colors.blue[100],

shape: RoundedRectangleBorder(

borderRadius:
BorderRadius.circular(12),
),
),

child: isLoading

? const CircularProgressIndicator(
color: Colors.white)

    : const Text(

"افزودن شماره سریال جدید",

style: TextStyle(
fontSize: 16,
color: Colors.black,
),
),
),
),
  const SizedBox(height: 10),

  SizedBox(

    width: double.infinity,

    height:45,

    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[100],
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {


        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (context)=>
            const BuyerSearchPage(),

          ),

        );
      },

      icon: const Icon(
        Icons.search,
        color: Colors.blue,
      ),
      label: const Text(
        " صفحه ی جستجو بر مبنای خریدار",
      ),

    ),

  ),
const SizedBox(height: 20),
  SizedBox(

    width: double.infinity,

    height:45,

    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[100],
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {


        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (context)=>
            const EditPage(),

          ),

        );
      },

      icon: const Icon(
        Icons.search,
        color: Colors.blue,
      ),


      label: const Text(
        " صفحه ویرایش اطلاعات ثبت شده",
      ),


    ),

  ),
  const SizedBox(height: 20),

Card(

elevation: 3,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),

child: ListTile(
  contentPadding: EdgeInsets.all(2),
dense: true,

leading: const Icon(
Icons.category,
color: Colors.green,
),

title: const Text("نام محصول"),

subtitle: Text(product),
),
),

Card(

elevation: 3,

shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),

child: ListTile(
  contentPadding: EdgeInsets.all(2),
dense: true,

leading: const Icon(
Icons.person,
color: Colors.blue,
),

title: const Text("تولیدکننده"),

subtitle: Text(producer),
),
),

Card(

elevation: 3,

shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),

child: ListTile(
  contentPadding: EdgeInsets.all(2),
dense: true,

leading: const Icon(
Icons.verified,
color: Colors.red,
),

title: const Text("اپراتور کنترل کیفی"),

subtitle: Text(qc),
),
),

const SizedBox(height: 30),

  Autocomplete<String>(

    optionsBuilder:
        (TextEditingValue textEditingValue) {

      if (textEditingValue.text.isEmpty) {
        return buyerNames;
      }

      return buyerNames.where(
            (String name) => name
            .toLowerCase()
            .contains(
          textEditingValue.text.toLowerCase(),
        ),
      );
    },

    onSelected: (String selection) {

      buyerController.text = selection;
    },

    fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
        ) {

      // همگام‌سازی با controller فعلی
      fieldController.text = buyerController.text;

      fieldController.addListener(() {

        buyerController.text =
            fieldController.text;
      });

      return TextField(

        controller: fieldController,

        focusNode: focusNode,

        decoration: InputDecoration(

          labelText: "نام خریدار",

          prefixIcon: const Icon(
            Icons.person_outline,
            color: Colors.blue,
          ),

          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(15),
          ),
        ),
      );
    },
  ),
  const SizedBox(height: 30),
  TextField(
    controller: patietController,
    decoration: InputDecoration(
      labelText: "نام بیمار",
      prefixIcon: const Icon(
        Icons.person_outline,
        color: Colors.green,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  ),
const SizedBox(height: 30),
  TextField(
    controller: UIDController,
    decoration: InputDecoration(
      labelText: "کد UID",
      prefixIcon: const Icon(
        Icons.code,
        color: Colors.purple,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  ),
  const SizedBox(height: 30),
TextField(

controller: exitDateController,

readOnly: true,

onTap: pickDate,

decoration: InputDecoration(

labelText: "تاریخ خروج",

prefixIcon: const Icon(
Icons.calendar_month,
color: Colors.red,
),

border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(15),
),
),
),

  const SizedBox(height: 30),
  TextField(

    controller: guaDateController,

    readOnly: true,

    onTap: pickDate2,

    decoration: InputDecoration(

      labelText: "تاریخ شروع گارانتی",

      prefixIcon: const Icon(
        Icons.calendar_month,
        color: Colors.grey,
      ),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(15),
      ),
    ),
  ),

  const SizedBox(height: 30),
  TextField(
    controller: descriptionController,
    decoration: InputDecoration(
      labelText: "توضیحات",
      prefixIcon: const Icon(
        Icons.description,
        color: Colors.orange,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  ),

const SizedBox(height: 30),

SizedBox(

width: double.infinity,

height: 45,

child: ElevatedButton.icon(

onPressed: saveSale,

icon: const Icon(
Icons.save,
color: Colors.blue,
),

label:
const Text("ذخیره "),

style: ElevatedButton.styleFrom(

backgroundColor:
Colors.cyan[200],

foregroundColor:
Colors.black,

shape: RoundedRectangleBorder(

borderRadius:
BorderRadius.circular(12),
),
),
),
),


const SizedBox(height: 30),

  SizedBox(
    width: double.infinity,
    height: 45,

    child: ElevatedButton.icon(

      onPressed: deleteSale,

      icon: const Icon(
        Icons.delete,
        color: Colors.white,
      ),

      label: const Text(
        "حذف ",
      ),

      style: ElevatedButton.styleFrom(

        backgroundColor: Colors.red,

        foregroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(12),
        ),
      ),
    ),
  ),
const SizedBox(height: 30),
SizedBox(

width: double.infinity,

height: 45,

child: ElevatedButton.icon(

onPressed: exportCSV,

icon: Icon(
Icons.download,
color: Colors.red[900],
),

label:
const Text("اکسل خروجی"),

style: ElevatedButton.styleFrom(

backgroundColor:
Colors.teal[100],

foregroundColor:
Colors.black,

shape: RoundedRectangleBorder(

borderRadius:
BorderRadius.circular(12),
),
),
),
),
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

