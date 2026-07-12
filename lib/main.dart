
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

void main() {
runApp(MyApp());
}

class MyApp extends StatelessWidget {

@override
Widget build(BuildContext context) {

return MaterialApp(

debugShowCheckedModeBanner: false,

title: 'Serial Search',

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

TextEditingController serialController =
TextEditingController();

TextEditingController buyerController =
TextEditingController();

TextEditingController exitDateController =
TextEditingController();

bool isLoading = false;

String product = "-";
String producer = "-";
String qc = "-";

Future<void> searchSerial() async {

if (serialController.text.isEmpty) {

ScaffoldMessenger.of(context).showSnackBar(

SnackBar(
content: Text("Serial Number را وارد کنید"),
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
content: Text("Serial پیدا نشد"),
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

setState(() {
isLoading = false;
});
}

Future<void> saveSale() async {

try {

String serial =
serialController.text.trim();

String buyer =
buyerController.text.trim();

String date =
exitDateController.text.trim();

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

"exit_date": date,
},
);

var data =
jsonDecode(response.body);

if (data["status"] == "ok") {

ScaffoldMessenger.of(context).showSnackBar(

SnackBar(
content: Text("Saved Successfully"),
),
);

} else {

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

DateTime? pickedDate = await showDatePicker(

context: context,

initialDate: DateTime.now(),

firstDate: DateTime(2020),

lastDate: DateTime(2100),
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
"Serial,Product,Producer,QC Operator,Buyer,Exit Date");

for (var item in data) {

csv.writeln(
"${item["serial"]},"
"${item["product"]},"
"${item["producer"]},"
"${item["qc_operator"]},"
"${item["buyer_name"]},"
"${item["exit_date"]}"
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

body: Center(

child: Container(

width:
MediaQuery.of(context).size.width > 700
? 800
    : double.infinity,

padding: const EdgeInsets.all(20),

child: SingleChildScrollView(

child: Column(

children: [

const SizedBox(height: 10),

TextField(

controller: serialController,

decoration: InputDecoration(

labelText: "Serial Number",

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

"Search",

style: TextStyle(
fontSize: 16,
color: Colors.black,
),
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

title: const Text("Product"),

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

title: const Text("Producer"),

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

title: const Text("QC Operator"),

subtitle: Text(qc),
),
),

const SizedBox(height: 30),

TextField(

controller: buyerController,

decoration: InputDecoration(

labelText: "Buyer Name",

prefixIcon: const Icon(
Icons.person_outline,
color: Colors.blue,
),

border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(15),
),
),
),

const SizedBox(height: 30),

TextField(

controller: exitDateController,

readOnly: true,

onTap: pickDate,

decoration: InputDecoration(

labelText: "Exit Date",

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
const Text("Save Sale"),

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

onPressed: exportCSV,

icon: Icon(
Icons.download,
color: Colors.red[900],
),

label:
const Text("Export CSV"),

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
);
}
}

