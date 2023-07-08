import 'dart:convert';

import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scratcher/scratcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScratcherViewerScreen extends StatefulWidget {
  @override
  State<ScratcherViewerScreen> createState() => _ScratcherViewerScreenState();
}

class _ScratcherViewerScreenState extends State<ScratcherViewerScreen> {
  List? scratcherList;
  bool loading = true;
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      Map newData = await getScratcherList();

      if (newData['status']) {
        setState(() {
          loading = false;
          scratcherList = newData['data'];
        });
      }
    });

    super.initState();
  }

  getScratcherList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.TOKEN);
    final responseOrder = await http.get(
        Uri.parse('${AppConstants.BASE_URL}/api/v1/my-scratchers'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${token}',
        });

    print('API RESPONSE');
    print(responseOrder.body);
    print(responseOrder.statusCode);
    print(responseOrder.reasonPhrase);
    print(json.decode(responseOrder.body)['data']);
    print('API RESPONSE');
    return await json.decode(responseOrder.body);
  }

  applyCoupon(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.TOKEN);
    print('${AppConstants.BASE_URL}/api/v1/user-scratcher-apply/${id}}');
    final response = await http.get(
      Uri.parse('${AppConstants.BASE_URL}/api/v1/user-scratcher-apply/${id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token}',
      },
    );
    final res = await json.decode(response.body);
    print(res);
  }

  Widget build(BuildContext context) {
    if (scratcherList != null && scratcherList != []) {
      print('LIST-----------------------');
      for (var i in scratcherList!) print(i);
    }
    return Scaffold(
      appBar: CustomAppBar(title: 'My Scratchers'.tr),
      body: Center(
          child: Container(
        width: Dimensions.WEB_MAX_WIDTH,
        height: MediaQuery.of(context).size.height,
        color: GetPlatform.isWeb ? Colors.white : Theme.of(context).cardColor,
        child: loading
            ? Center(
                child: SizedBox(
                    height: 50, width: 50, child: CircularProgressIndicator()),
              )
            : Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  children: (scratcherList != null && scratcherList != [])
                      ? [
                          for (var i in scratcherList!)
                            InkWell(
                              onTap: () {
                                showPopUp(i);
                              },
                              child: Card(
                                elevation: 10, //shadow elevation for card
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: i['checked'] == 0
                                      ? Scratcher(
                                          enabled: false,
                                          brushSize: 50,
                                          threshold: 70,
                                          color: Colors.red,
                                          image: Image.asset(
                                            "assets/image/scratcher.png",
                                            fit: BoxFit.fill,
                                          ),
                                          onChange: (value) => {
                                            if (value == 100.0)
                                              {
                                                print(
                                                    "Scratch progress: $value%")
                                              }
                                          },
                                          onThreshold: () {
                                            applyCoupon(i['id']);
                                            showCustomSnackBar(
                                                'Scratch amount added to your wallet',
                                                isError: false);
                                          },
                                          child: Image.network(
                                            '${AppConstants.BASE_URL}/public/images/${i['scratch']}',
                                            fit: BoxFit.fill,
                                          ),
                                        )
                                      : Image.network(
                                          '${AppConstants.BASE_URL}/public/images/${i['scratch']}'),
                                ),
                              ),
                            )
                        ]
                      : [Text('No Scratcher')],
                )),
      )),
    );
  }

  showPopUp(var i) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            await setS123();
            Get.back();
            refresh();
            return false;
          },
          child: GestureDetector(
            onTap: () {
              setState(() {
                loading = true;
              });
              Get.back();
              refresh();
            },
            child: Container(
              color: Colors.transparent,
              height: Get.height,
              width: Get.width,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 10, //shadow elevation for card
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: i['checked'] == 0
                            ? Scratcher(
                                enabled: true,
                                brushSize: 70,
                                threshold: 50,
                                color: Colors.red,
                                image: Image.asset(
                                  "assets/image/scratcher.png",
                                  fit: BoxFit.fill,
                                ),
                                onChange: (value) => {
                                  if (value == 100.0)
                                    {print("Scratch progress: $value%")}
                                },
                                onThreshold: () => {
                                  applyCoupon(i['id']),
                                  showCustomSnackBar(
                                      'Scratch amount added to your wallet',
                                      isError: false),
                                },
                                child: Image.network(
                                  '${AppConstants.BASE_URL}/public/images/${i['scratch']}',
                                  fit: BoxFit.fill,
                                ),
                              )
                            : Image.network(
                                '${AppConstants.BASE_URL}/public/images/${i['scratch']}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void refresh() async {
    Map newData = await getScratcherList();
    if (newData['status']) {
      setState(() {
        loading = false;
        scratcherList = newData['data'];
      });
    }
  }

  setS123() {
    setState(() {
      loading = true;
    });
    return true;
  }
}
