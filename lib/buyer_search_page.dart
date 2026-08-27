import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyerSearchPage extends StatefulWidget {
  const BuyerSearchPage({super.key});

  @override
  State<BuyerSearchPage> createState() => _BuyerSearchPageState();
}

class _BuyerSearchPageState extends State<BuyerSearchPage> {

  TextEditingController buyerController =
  TextEditingController();

  bool isLoading = false;

  List<dynamic> sales = [];

  Future<void> searchBuyer() async {

    String buyer = buyerController.text.trim();

    if (buyer.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("نام خریدار را وارد کنید"),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
      sales.clear();
    });

    try {

      var url = Uri.parse(
        "https://mohammadreza-karimi.ir/api/search_buyer.php"
            "?buyer=${Uri.encodeComponent(buyer)}",
      );

      var response = await http.get(url);

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      var data = jsonDecode(response.body);

      if (data["status"] == "ok") {

        setState(() {
          sales = List<dynamic>.from(
            data["data"] ?? [],
          );
        });

        if (sales.isEmpty) {

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "هیچ رکوردی برای این خریدار پیدا نشد",
              ),
            ),
          );
        }

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "خطا در جستجو",
            ),
          ),
        );
      }

    } catch (e) {

      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطا: $e"),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {

    buyerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Search Buyer",
        ),

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

              child: Container(

                width:
                MediaQuery.of(context).size.width > 700
                    ? 800
                    : double.infinity,

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,

                  children: [

                    const SizedBox(height: 10),

                    TextField(

                      controller: buyerController,

                      decoration: InputDecoration(

                        labelText: "نام خریدار",

                        prefixIcon: const Icon(
                          Icons.person_search,
                          color: Colors.blue,
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(

                      height: 45,

                      child: ElevatedButton.icon(

                        onPressed:
                        isLoading
                            ? null
                            : searchBuyer,

                        icon: const Icon(
                          Icons.search,
                        ),

                        label: isLoading

                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )

                            : const Text(
                          "جستجو",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          Colors.blue[100],

                          foregroundColor:
                          Colors.black,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    if (sales.isNotEmpty)

                      Card(

                        child: Padding(

                          padding:
                          const EdgeInsets.all(15),

                          child: Text(
                            "تعداد رکوردها: ${sales.length}",

                            style:
                            const TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    ...sales.map(

                          (item) {

                        return Card(

                          elevation: 3,

                          margin:
                          const EdgeInsets.only(
                            bottom: 15,
                          ),

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(15),
                          ),

                          child: Padding(

                            padding:
                            const EdgeInsets.all(15),

                            child: Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                Row(

                                  children: [

                                    const Icon(
                                      Icons
                                          .confirmation_number,
                                      color: Colors.red,
                                    ),

                                    const SizedBox(width: 8),

                                    Expanded(

                                      child: Text(
                                        "شماره سریال: "
                                            "${item["serial"] ?? "-"}",

                                        style:
                                        const TextStyle(
                                          fontSize: 17,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(),

                                _buildInfoRow(
                                  Icons.category,
                                  "محصول",
                                  item["product"],
                                  Colors.green,
                                ),

                                _buildInfoRow(
                                  Icons.person,
                                  "تولیدکننده",
                                  item["producer"],
                                  Colors.blue,
                                ),

                                _buildInfoRow(
                                  Icons.verified,
                                  "اپراتور کنترل کیفی",
                                  item["qc_operator"],
                                  Colors.red,
                                ),

                                _buildInfoRow(
                                  Icons.person_outline,
                                  "نام بیمار",
                                  item["patient_name"],
                                  Colors.green,
                                ),

                                _buildInfoRow(
                                  Icons.calendar_month,
                                  "تاریخ خروج",
                                  item["exit_date"],
                                  Colors.orange,
                                ),

                                if (item["description"] !=
                                    null &&
                                    item["description"]
                                        .toString()
                                        .isNotEmpty)

                                  _buildInfoRow(
                                    Icons.description,
                                    "توضیحات",
                                    item["description"],
                                    Colors.deepPurple,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _buildInfoRow(
      IconData icon,
      String title,
      dynamic value,
      Color iconColor,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 12),

      child: Row(

        crossAxisAlignment:
        CrossAxisAlignment.start,

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
}