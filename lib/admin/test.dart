import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:online_ombor/models/product_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  var category_id;
  var category_name;

  ProductPage({super.key, this.category_id, this.category_name});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {

  late final _productNameController = TextEditingController();
  late final _productDescriptionController = TextEditingController();
  late final _productPriceController = TextEditingController();
  late final _productBenefitController = TextEditingController();
  late final _productStockController = TextEditingController();
  late final _productNumberController = TextEditingController();

  var productId = [];
  var productName = [];
  var productDescription = [];
  var productPrice = [];
  var productCategoryId = [];
  var productBenefit = [];
  var productStock = [];
  var productStatus = [];
  var productDate = [];
  var productSellerId = [];
  var productNumber = [];

  //var _productList = [];

  var userName = '';
  var userId = '';
  var userSurname = '';
  var userPhone = '';
  var userRole = '';
  var userStatus = '';
  var userBlocked = false;
  var userNames = '';
  var minWeight = '';
  var maxWeight = '';
  var minHeight = '';
  var maxHeight = '';
  var _isLoad = true;

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  Future<void> _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('name') ?? '';
    userId = prefs.getString('userid') ?? '';
    userSurname = prefs.getString('surname') ?? '';
    userPhone = prefs.getString('phone') ?? '';
    userRole = prefs.getString('role') ?? '';
    userStatus = prefs.getString('userstatus') ?? '';
    userBlocked = prefs.getBool('blocked') ?? false;
    userNames = prefs.getString('username') ?? '';
  }

  Future<void> _getProductsByCategory() async {
    var catId = widget.category_id;
    final response = await http.get(
      Uri.parse(
          'https://golalang-online-sklad-production.up.railway.app/getProductsByCategory?categoryId=$catId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      productId.clear();
      productName.clear();
      productDescription.clear();
      productPrice.clear();
      productCategoryId.clear();
      productBenefit.clear();
      productStock.clear();
      productStatus.clear();
      productDate.clear();
      productSellerId.clear();
      productNumber.clear();
      if (data['status'] == 'success' && data['data'] == null) {
        print('No data');
        _isLoad = false;
        setState(() {});
        return;
      }
      for (var i = 0; i < data['data'].length; i++) {
        _isLoad = false;
        setState(() {
          productId.add(data['data'][i]['product_id']);
          productName.add(data['data'][i]['product_name']);
          productDescription.add(data['data'][i]['product_desc']);
          productPrice.add(data['data'][i]['product_price']);
          productCategoryId.add(data['data'][i]['product_cat_id']);
          productBenefit.add(data['data'][i]['product_benefit']);
          productStock.add(data['data'][i]['product_stock']);
          productStatus.add(data['data'][i]['product_status']);
          productDate.add(data['data'][i]['product_date']);
          productSellerId.add(data['data'][i]['product_seller']);
          productNumber.add(data['data'][i]['product_number']);

          // _productList.add(ProductList(
          //   productId: data['data'][i]['product_id'],
          //   productName: data['data'][i]['product_name'],
          //   productDescription: data['data'][i]['product_desc'],
          //   productPrice: data['data'][i]['product_price'],
          //   productCatId: data['data'][i]['product_cat_id'],
          //   productBenefit: data['data'][i]['product_benefit'],
          //   productStock: data['data'][i]['product_stock'],
          //   productStatus: data['data'][i]['product_status'],
          //   productDate: data['data'][i]['product_date'],
          //   productSeller: data['data'][i]['product_seller'],
          //   productNumber: data['data'][i]['product_number'],
          // ));
        });
      }

    } else {
      _isLoad = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          duration: Duration(milliseconds: 1700),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _addProduct() async {
    var price = int.parse(_productPriceController.text);
    var benefit = int.parse(_productBenefitController.text);
    var number = int.parse(_productNumberController.text);
    _productStockController.text = 'active';
    final response = await http.post(
      Uri.parse(
          'https://golalang-online-sklad-production.up.railway.app/addProduct'),
      body: jsonEncode(<Object, Object>{
        'product_name': _productNameController.text,
        'product_desc': _productDescriptionController.text,
        'product_price': price,
        'product_cat_id': widget.category_id,
        'product_benefit': benefit,
        'product_stock': _productStockController.text,
        'product_status': 'sell',
        'product_seller': userId,
        'product_number': number,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      _productNameController.clear();
      _productDescriptionController.clear();
      _productPriceController.clear();
      _productBenefitController.clear();
      _productStockController.clear();
      _productNumberController.clear();
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mahsulot qo\'shildi'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            duration: Duration(milliseconds: 1700),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        _getProductsByCategory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mahsulot qo\'shilmadi'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            duration: Duration(milliseconds: 1700),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
      _getProductsByCategory();
    } else {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection or server error'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          duration: Duration(milliseconds: 2700),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  //show dialog add product
  Future<void> _showDialogAddProduct() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yangi mahsulot qo\'shish'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 221, 221, 221),
                        border: Border.all(
                            color: const Color.fromARGB(255, 221, 221, 221),
                            width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        cursorColor: Colors.deepPurpleAccent,
                        controller: _productNameController,
                        textAlign: TextAlign.left,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          border: InputBorder.none,
                          hintText: 'Mahsulot nomi',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 221, 221, 221),
                        border: Border.all(
                            color: const Color.fromARGB(255, 221, 221, 221),
                            width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        cursorColor: Colors.deepPurpleAccent,
                        controller: _productDescriptionController,
                        textAlign: TextAlign.left,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          border: InputBorder.none,
                          hintText: 'Mahsulot izohi',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 221, 221, 221),
                        border: Border.all(
                            color: const Color.fromARGB(255, 221, 221, 221),
                            width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        cursorColor: Colors.deepPurpleAccent,
                        controller: _productPriceController,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          border: InputBorder.none,
                          hintText: 'Mahsulot narxi',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 221, 221, 221),
                        border: Border.all(
                            color: const Color.fromARGB(255, 221, 221, 221),
                            width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        cursorColor: Colors.deepPurpleAccent,
                        controller: _productBenefitController,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          border: InputBorder.none,
                          hintText: 'Mahsulot foydasi',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 221, 221, 221),
                            border: Border.all(
                                color: const Color.fromARGB(255, 221, 221, 221),
                                width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _addProduct();
                            },
                            icon: SvgPicture.asset(
                              'assets/minusIcon.svg',
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 221, 221, 221),
                            border: Border.all(
                                color: const Color.fromARGB(255, 221, 221, 221),
                                width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: TextField(
                              cursorColor: Colors.deepPurpleAccent,
                              controller: _productNumberController,
                              textAlign: TextAlign.center,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                contentPadding:
                                EdgeInsets.only(left: 10, right: 10),
                                border: InputBorder.none,
                                hintText: 'Mahsulot miqdori',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 221, 221, 221),
                            border: Border.all(
                                color: const Color.fromARGB(255, 221, 221, 221),
                                width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _addProduct();
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('bekor qilish'),
              onPressed: () {
                _addProduct();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('qo\'shish'),
              onPressed: () {
                setState(() {
                  _isLoad = true;
                });
                _addProduct();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _getUser();
    _getProductsByCategory();
    super.initState();
    checkInternetConnection().then((value) {
      if (!value) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Internetga ulanish yo\'q!'),
              backgroundColor: Colors.red,
            )
        );
      }
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _productPriceController.dispose();
    _productBenefitController.dispose();
    _productStockController.dispose();
    _productNumberController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50), // here the desired height
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.4,
          actionsIconTheme: const IconThemeData(color: Colors.black),
          iconTheme: const IconThemeData(color: Colors.black),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.category_name,
                  style: const TextStyle(fontSize: 20, color: Colors.black)),
              const Expanded(
                child: SizedBox(),
              ),
              SizedBox(
                height: 30,
                width: MediaQuery.of(context).size.width / 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 221, 221, 221),
                    border: Border.all(
                        color: const Color.fromARGB(255, 221, 221, 221),
                        width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    cursorColor: Colors.deepPurpleAccent,
                    textAlign: TextAlign.justify,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      setState(() {
                        //search products by name

                      });
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10, right: 10),
                      border: InputBorder.none,
                      hintText: 'Qidirish',
                      suffixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 50,
              ),
              IconButton(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.white,
                color: Colors.white,
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/userIcon.svg',
                  height: 25,
                  width: 25,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                GestureDetector(
                  onTap: () {
                    //read product
                  },
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.35),
                              //color: Color.fromARGB(255, 221, 221, 221),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                height:
                                MediaQuery.of(context).size.height / 50),
                            //product qo`shish
                            Row(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 50,
                                ),
                                const Text(
                                  'Yangi mahsulot',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Expanded(
                                  child: SizedBox(),
                                ),
                                IconButton(
                                    onPressed: () {
                                      //product qo`shish
                                      _showDialogAddProduct();
                                    },
                                    icon: const Icon(
                                      Icons.add_circle_outline_outlined,
                                      color: Colors.deepPurpleAccent,
                                      size: 30,
                                    )),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 35,
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                MediaQuery.of(context).size.height / 50),
                          ],
                        ),
                      ),
                      for (var i = 0; i < productId.length; i++)
                        if (productId.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.35),
                                  //color: Color.fromARGB(255, 221, 221, 221),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        50),
                                Row(
                                  children: [
                                    SizedBox(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.01),
                                    Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: SvgPicture.asset(
                                        'assets/productIcon.svg',
                                        height: 50,
                                        width: 50,
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.01),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            productName[i],
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            '${productPrice[i]} so\'m',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            productDescription[i],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: SvgPicture.asset(
                                        'assets/editIcon.svg',
                                        height: 25,
                                        width: 25,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.005,
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: SvgPicture.asset(
                                        'assets/deleteIcon.svg',
                                        height: 25,
                                        width: 25,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          40,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        50),
                              ],
                            ),
                          ),
                      if (productId.isEmpty)
                        Container(
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.35),
                                //color: Color.fromARGB(255, 221, 221, 221),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                  height:
                                  MediaQuery.of(context).size.height / 50),
                              //hozircha mahsulot yo`q
                              //progress bar
                              const Center(
                                child: Text(
                                  'Hozircha mahsulot yo`q',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                  height:
                                  MediaQuery.of(context).size.height / 50),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            //progress bar
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
              IconButton(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: const Color.fromRGBO(217, 217, 217, 100),
                onPressed: () {
                  productId.clear();
                  productName.clear();
                  productDescription.clear();
                  productPrice.clear();
                  productCategoryId.clear();
                  productBenefit.clear();
                  productStock.clear();
                  productStatus.clear();
                  productDate.clear();
                  productSellerId.clear();
                  productNumber.clear();
                  setState(() {_isLoad = true;});
                  _getProductsByCategory();
                },
                icon: const Icon(
                  Icons.refresh,
                  size: 30,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
              Text("Jami: ${productId.length}",
                  style: const TextStyle(fontSize: 20, color: Colors.black)),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
              if (_isLoad)
                const CircularProgressIndicator(
                  color: Colors.deepPurpleAccent,
                ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 50,
          ),
        ],
      ),
    );
  }
}