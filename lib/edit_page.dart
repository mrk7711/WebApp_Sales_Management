import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {

  // ==================================================
  // Controllers
  // ==================================================

  TextEditingController serialController =
  TextEditingController();

  TextEditingController buyerController =
  TextEditingController();

  TextEditingController patientController =
  TextEditingController();

  TextEditingController UIDController =
  TextEditingController();

  TextEditingController exitDateController =
  TextEditingController();

  TextEditingController guaDateController =
  TextEditingController();

  TextEditingController descriptionController =
  TextEditingController();


  // ==================================================
  // Variables
  // ==================================================

  bool isLoading = false;

  bool isFound = false;


  // ==================================================
  // Search Sale
  // ==================================================

  Future<void> searchSale() async {

    String serial =
    serialController.text.trim();

    if (serial.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "شماره سریال را وارد کنید",
          ),
        ),
      );

      return;
    }

    setState(() {

      isLoading = true;

      isFound = false;

    });


    try {

      // ==================================================
      // API
      // ==================================================

      var url = Uri.parse(
        "https://mohammadreza-karimi.ir/api/search_sale.php"
            "?serial=${Uri.encodeComponent(serial)}",
      );


      // ==================================================
      // GET
      // ==================================================

      var response =
      await http.get(url);


      print(
        "SEARCH STATUS: ${response.statusCode}",
      );

      print(
        "SEARCH RESPONSE: ${response.body}",
      );


      // ==================================================
      // JSON
      // ==================================================

      var data =
      jsonDecode(response.body);


      // ==================================================
      // Success
      // ==================================================

      if (data["status"] == "ok") {

        var item = data["data"];


        setState(() {

          buyerController.text =
              item["buyer_name"] ?? "";

          patientController.text =
              item["patient_name"] ?? "";

          UIDController.text =
              item["uid"] ?? "";

          exitDateController.text =
              item["exit_date"] ?? "";

          guaDateController.text =
              item["guarantee_date"] ?? "";

          descriptionController.text =
              item["description"] ?? "";

          isFound = true;

        });


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "اطلاعات پیدا شد",
            ),
          ),
        );

      }

      // ==================================================
      // Not Found
      // ==================================================

      else {

        setState(() {

          buyerController.clear();

          patientController.clear();

          UIDController.clear();

          exitDateController.clear();

          guaDateController.clear();

          descriptionController.clear();

          isFound = false;

        });


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ??
                  "سریال پیدا نشد",
            ),
          ),
        );
      }

    }

    // ==================================================
    // Error
    // ==================================================

    catch (e) {

      print(
        "SEARCH ERROR: $e",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "خطا: $e",
          ),
        ),
      );

    }

    // ==================================================
    // Finish
    // ==================================================

    finally {

      setState(() {

        isLoading = false;

      });

    }
  }


  // ==================================================
  // Update Sale
  // ==================================================

  Future<void> updateSale() async {

    String serial =
    serialController.text.trim();

    if (serial.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "شماره سریال وارد نشده است",
          ),
        ),
      );

      return;
    }


    if (!isFound) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "ابتدا سریال را جستجو کنید",
          ),
        ),
      );

      return;
    }


    setState(() {

      isLoading = true;

    });


    try {

      // ==================================================
      // API
      // ==================================================

      var url = Uri.parse(
        "https://mohammadreza-karimi.ir/api/update_sale.php",
      );


      // ==================================================
      // POST
      // ==================================================

      var response = await http.post(

        url,

        headers: {

          "Content-Type":
          "application/x-www-form-urlencoded",

        },

        body: {

          "serial": serial,

          "buyer_name":
          buyerController.text.trim(),

          "patient_name":
          patientController.text.trim(),

          "uid":
          UIDController.text.trim(),

          "exit_date":
          exitDateController.text.trim(),

          "guarantee_date":
          guaDateController.text.trim(),

          "description":
          descriptionController.text.trim(),

        },
      );


      print(
        "UPDATE STATUS: ${response.statusCode}",
      );

      print(
        "UPDATE RESPONSE: ${response.body}",
      );


      // ==================================================
      // JSON
      // ==================================================

      var data =
      jsonDecode(response.body);


      // ==================================================
      // Success
      // ==================================================

      if (data["status"] == "ok") {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "اطلاعات با موفقیت آپدیت شد",
            ),
          ),
        );

      }

      // ==================================================
      // Error
      // ==================================================

      else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ??
                  "Update failed",
            ),
          ),
        );

      }

    }

    // ==================================================
    // Exception
    // ==================================================

    catch (e) {

      print(
        "UPDATE ERROR: $e",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "خطا: $e",
          ),
        ),
      );

    }

    // ==================================================
    // Finish
    // ==================================================

    finally {

      setState(() {

        isLoading = false;

      });

    }
  }


  // ==================================================
  // Pick Date
  // ==================================================

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


  // ==================================================
  // Dispose
  // ==================================================

  @override
  void dispose() {

    serialController.dispose();

    buyerController.dispose();

    UIDController.dispose();

    patientController.dispose();

    exitDateController.dispose();

    guaDateController.dispose();

    descriptionController.dispose();

    super.dispose();
  }


  // ==================================================
  // Build
  // ==================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // ==================================================
      // AppBar
      // ==================================================

      appBar: AppBar(

        title: const Text(
          "ویرایش براساس شماره سریال",
        ),

        centerTitle: true,

        backgroundColor:
        Colors.blue[200],

        foregroundColor:
        Colors.black,

      ),


      // ==================================================
      // Body
      // ==================================================

      body: Directionality(

        textDirection:
        TextDirection.rtl,

        child: SingleChildScrollView(

          child: Padding(

            padding:
            const EdgeInsets.all(20),

            child: Align(

              alignment:
              Alignment.topCenter,

              child: Container(

                width:
                MediaQuery.of(context)
                    .size
                    .width >
                    700
                    ? 800
                    : double.infinity,

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,

                  children: [

                    const SizedBox(
                      height: 10,
                    ),


                    // ==================================================
                    // Serial
                    // ==================================================

                    TextField(

                      controller:
                      serialController,

                      textDirection:
                      TextDirection.ltr,

                      textAlign:
                      TextAlign.left,

                      decoration:
                      InputDecoration(

                        labelText:
                        "شماره سریال را وارد نمایید",

                        prefixIcon:
                        const Icon(
                          Icons.search,
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              15),
                        ),

                      ),
                    ),


                    const SizedBox(
                      height: 20,
                    ),


                    // ==================================================
                    // Search Button
                    // ==================================================

                    SizedBox(

                      height: 45,

                      child:
                      ElevatedButton.icon(

                        onPressed:
                        isLoading
                            ? null
                            : searchSale,

                        icon:
                        const Icon(
                          Icons.search,
                        ),

                        label:

                        isLoading

                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,
                            color:
                            Colors.white,
                          ),
                        )

                            : const Text(
                          "جستجو",
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
                            BorderRadius.circular(
                                12),
                          ),

                        ),
                      ),
                    ),


                    const SizedBox(
                      height: 30,
                    ),


                    // ==================================================
                    // Fields
                    // ==================================================

                    if (isFound) ...[

                      TextField(

                        controller:
                        buyerController,

                        decoration:
                        InputDecoration(

                          labelText:
                          "نام خریدار",

                          prefixIcon:
                          const Icon(
                            Icons.person,
                            color:
                            Colors.blue,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                15),
                          ),

                        ),
                      ),


                      const SizedBox(
                        height: 25,
                      ),


                      TextField(

                        controller:
                        patientController,

                        decoration:
                        InputDecoration(

                          labelText:
                          "نام بیمار",

                          prefixIcon:
                          const Icon(
                            Icons.person_outline,
                            color:
                            Colors.green,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                15),
                          ),

                        ),
                      ),


                      const SizedBox(
                        height: 25,
                      ),

                      TextField(

                        controller:
                        UIDController,

                        decoration:
                        InputDecoration(

                          labelText:
                          "کد UID",

                          prefixIcon:
                          const Icon(
                            Icons.code,
                            color:
                            Colors.purple,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                15),
                          ),

                        ),
                      ),


                      const SizedBox(
                        height: 25,
                      ),
                      TextField(

                        controller:
                        exitDateController,

                        readOnly:
                        true,

                        onTap:
                        pickDate,

                        decoration:
                        InputDecoration(

                          labelText:
                          "تاریخ خروج",

                          prefixIcon:
                          const Icon(
                            Icons.calendar_month,
                            color:
                            Colors.red,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                15),
                          ),

                        ),
                      ),


                      const SizedBox(
                        height: 25,
                      ),

                      TextField(

                        controller:
                        guaDateController,

                        readOnly:
                        true,

                        onTap:
                        pickDate2,

                        decoration:
                        InputDecoration(

                          labelText:
                          "تاریخ شروع گارانتی",

                          prefixIcon:
                          const Icon(
                            Icons.calendar_month,
                            color:
                            Colors.grey,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                15),
                          ),

                        ),
                      ),


                      const SizedBox(
                        height: 25,
                      ),
                      TextField(

                        controller:
                        descriptionController,

                        maxLines:
                        3,

                        decoration:
                        InputDecoration(

                          labelText:
                          "توضیحات",

                          prefixIcon:
                          const Icon(
                            Icons.description,
                            color:
                            Colors.orange,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                15),
                          ),

                        ),
                      ),


                      const SizedBox(
                        height: 30,
                      ),


                      // ==================================================
                      // Update Button
                      // ==================================================

                      SizedBox(

                        height: 45,

                        child:
                        ElevatedButton.icon(

                          onPressed:
                          isLoading
                              ? null
                              : updateSale,

                          icon:
                          const Icon(
                            Icons.update,
                            color:
                            Colors.white,
                          ),

                          label:
                          const Text(
                            "آپدیت اطلاعات",
                          ),

                          style:
                          ElevatedButton.styleFrom(

                            backgroundColor:
                            Colors.deepPurpleAccent,

                            foregroundColor:
                            Colors.white,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  12),
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