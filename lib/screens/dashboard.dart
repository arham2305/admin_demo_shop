import 'dart:io';

import 'package:admin_demo_shop/db/brand.dart';
import 'package:admin_demo_shop/db/category.dart';
import 'package:admin_demo_shop/db/product.dart';
import 'package:admin_demo_shop/models/task.dart';
import 'package:admin_demo_shop/providers/app_states.dart';
import 'package:admin_demo_shop/providers/products_provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

import 'dashboard-content.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _platformVersion = 'Unknown';

  List<charts.Series<Task, String>> _seriesPieData;
  int _selectedIndex = 0;
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  ProductService productService = ProductService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  List<Asset> images = List<Asset>();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory = '';
  String _currentBrand = '';
  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color red = Colors.red;
  List<String> selectedSizes = <String>[];
  List<String> colors = <String>[];
  bool onSale = false;
  bool featured = false;
  File _image1;
  String _error = 'No Error Dectected';
  bool isLoading = false;

  _getData() {
    var piedata = [
      new Task('Girls', 35.8, Color(0xff3366cc)),
      new Task('Women', 8.3, Color(0xff990099)),
      new Task('Pants', 10.8, Color(0xff109618)),
      new Task('Formal', 15.6, Color(0xfffdbe19)),
      new Task('Shoes', 19.2, Color(0xffff9900)),
      new Task('Other', 10.3, Color(0xffdc3912)),
    ];

    _seriesPieData.add(
      charts.Series(
        domainFn: (Task task, _) => task.task,
        measureFn: (Task task, _) => task.taskvalue,
        colorFn: (Task task, _) =>
            charts.ColorUtil.fromDartColor(task.colorval),
        id: 'Air Pollution',
        data: piedata,
        labelAccessorFn: (Task row, _) => '${row.taskvalue}',
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _seriesPieData = List<charts.Series<Task, String>>();
    _getData();
    _getCategories();
    _getBrands();
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(categories[i].data()['category']),
                value: categories[i].data()['category']));
      });
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandsDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(brands[i].data()['brand']),
                value: brands[i].data()['brand']));
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Row(
              children: [
                NavigationRail(
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  selectedIndex: _selectedIndex,
                  backgroundColor: Colors.white60,
                  elevation: 0.5,
                  destinations: [
                    NavigationRailDestination(
                      icon: ImageIcon(AssetImage("icons/dashboard.png")),
                      selectedIcon:
                          ImageIcon(AssetImage("icons/dashboard.png")),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: ImageIcon(AssetImage("icons/new-product.png")),
                      selectedIcon:
                          ImageIcon(AssetImage("icons/new-product.png")),
                      label: Text('Products'),
                    ),
                    NavigationRailDestination(
                      icon: ImageIcon(AssetImage("icons/category.png")),
                      selectedIcon: ImageIcon(AssetImage("icons/category.png")),
                      label: Text('Categories'),
                    ),
                    NavigationRailDestination(
                      icon: ImageIcon(AssetImage("icons/brand.png")),
                      selectedIcon: ImageIcon(
                        AssetImage(
                          "icons/brand.png",
                        ),
                        color: Colors.blue,
                      ),
                      label: Text('Brands'),
                    ),
                    NavigationRailDestination(
                      icon: ImageIcon(AssetImage("icons/online-shopping.png")),
                      selectedIcon: ImageIcon(
                        AssetImage("icons/online-shopping.png"),
                        color: Colors.blue,
                      ),
                      label: Text('Orders'),
                    ),
                  ],
                ),
                VerticalDivider(thickness: 1, width: 1),

//                // This is the main content.
//                Expanded(
//                  child: Center(
//                    child: Text('selectedIndex: $_selectedIndex'),
//                  ),
//                )
              ],
            ),
            if (_selectedIndex == 0)
              DashboardContent(seriesPieData: _seriesPieData)
            else if (_selectedIndex == 1)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: addProductScreen(productProvider),
                      )
                    ],
                  ),
                ),
              )
            else if (_selectedIndex == 2)
              Expanded(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Enter the Category',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 75.0),
                              child: TextFormField(
                                controller: categoryController,
                                decoration:
                                    InputDecoration(hintText: 'Category Name'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'You must enter the category name';
                                  } else if (value.length > 10) {
                                    return 'Category name can\'t have more than 10 letters';
                                  }
                                },
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, top: 25),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _categoryService.createCategory(
                                            categoryController.text.trim());
                                        _formKey.currentState.reset();
                                        Fluttertoast.showToast(
                                            msg: "Category Added");
                                        setState(() {
                                          _getCategories();
                                        });
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.green),
                                    ),
                                    child: Text("Add Category"),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_selectedIndex == 3)
              Expanded(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Enter the Brand',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 75.0),
                              child: TextFormField(
                                controller: brandController,
                                decoration:
                                    InputDecoration(hintText: 'Brand Name'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'You must enter the brand name';
                                  } else if (value.length > 30) {
                                    return 'Brand name can\'t have more than 30 letters';
                                  }
                                },
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 70.0, top: 25),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _brandService.createBrand(
                                            brandController.text.trim());
                                        _formKey.currentState.reset();
                                        Fluttertoast.showToast(
                                            msg: "Brand Added");
                                        setState(() {
                                          _getBrands();
                                        });
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.green),
                                    ),
                                    child: Text("Add Brand"),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
      Fluttertoast.showToast(msg: error);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  addProductScreen(ProductProvider productProvider) {
    return Form(
      key: _formKey,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 120,
                            child: OutlineButton(
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.5), width: 2.5),
                                onPressed: loadAssets,
//                                    () {
//                                  loadAssets
//                                  _selectImage(
//                                    ImagePicker.pickImage(
//                                        source: ImageSource.gallery),
//                                  );
//                                },
                                child: _displayChild1()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text('Available Colors'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          if (productProvider.selectedColors.contains('red')) {
                            productProvider.removeColor('red');
                          } else {
                            productProvider.addColors('red');
                          }
                          setState(() {
                            colors = productProvider.selectedColors;
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              color:
                                  productProvider.selectedColors.contains('red')
                                      ? Colors.blue
                                      : grey,
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          if (productProvider.selectedColors
                              .contains('yellow')) {
                            productProvider.removeColor('yellow');
                          } else {
                            productProvider.addColors('yellow');
                          }
                          setState(() {
                            colors = productProvider.selectedColors;
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              color: productProvider.selectedColors
                                      .contains('yellow')
                                  ? red
                                  : grey,
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              backgroundColor: Colors.yellow,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          if (productProvider.selectedColors.contains('blue')) {
                            productProvider.removeColor('blue');
                          } else {
                            productProvider.addColors('blue');
                          }
                          setState(() {
                            colors = productProvider.selectedColors;
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              color: productProvider.selectedColors
                                      .contains('blue')
                                  ? red
                                  : grey,
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          if (productProvider.selectedColors
                              .contains('green')) {
                            productProvider.removeColor('green');
                          } else {
                            productProvider.addColors('green');
                          }
                          setState(() {
                            colors = productProvider.selectedColors;
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              color: productProvider.selectedColors
                                      .contains('green')
                                  ? red
                                  : grey,
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          if (productProvider.selectedColors
                              .contains('white')) {
                            productProvider.removeColor('white');
                          } else {
                            productProvider.addColors('white');
                          }
                          setState(() {
                            colors = productProvider.selectedColors;
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              color: productProvider.selectedColors
                                      .contains('white')
                                  ? red
                                  : grey,
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              backgroundColor: white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          if (productProvider.selectedColors
                              .contains('black')) {
                            productProvider.removeColor('black');
                          } else {
                            productProvider.addColors('black');
                          }
                          setState(() {
                            colors = productProvider.selectedColors;
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              color: productProvider.selectedColors
                                      .contains('black')
                                  ? red
                                  : grey,
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              backgroundColor: black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text('Available Sizes'),
                ),

                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Checkbox(
                            value: selectedSizes.contains('XS'),
                            onChanged: (value) => changeSelectedSize('XS')),
                        Text('XS'),
                        Checkbox(
                            value: selectedSizes.contains('S'),
                            onChanged: (value) => changeSelectedSize('S')),
                        Text('S'),
                        Checkbox(
                            value: selectedSizes.contains('M'),
                            onChanged: (value) => changeSelectedSize('M')),
                        Text('M'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                            value: selectedSizes.contains('L'),
                            onChanged: (value) => changeSelectedSize('L')),
                        Text('L'),
                        Checkbox(
                            value: selectedSizes.contains('XL'),
                            onChanged: (value) => changeSelectedSize('XL')),
                        Text('XL'),
                        Checkbox(
                            value: selectedSizes.contains('XXL'),
                            onChanged: (value) => changeSelectedSize('XXL')),
                        Text('XXL'),
                      ],
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('Sale'),
                        SizedBox(
                          width: 10,
                        ),
                        Switch(
                            value: onSale,
                            onChanged: (value) {
                              setState(() {
                                onSale = value;
                              });
                            }),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('Featured'),
                        SizedBox(
                          width: 10,
                        ),
                        Switch(
                            value: featured,
                            onChanged: (value) {
                              setState(() {
                                featured = value;
                              });
                            }),
                      ],
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: productNameController,
                    decoration: InputDecoration(hintText: 'Product name'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'You must enter the product name';
                      } else if (value.length > 30) {
                        return 'Product name cant have more than 30 letters';
                      }
                    },
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 80,
                        child: Text(
                          'Category: ',
                          style: TextStyle(color: red),
                        ),
                      ),
                    ),
                    DropdownButton(
                      items: categoriesDropDown,
                      onChanged: changeSelectedCategory,
                      value: _currentCategory,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 80,
                        child: Text(
                          'Brand: ',
                          style: TextStyle(color: red),
                        ),
                      ),
                    ),
                    DropdownButton(
                      items: brandsDropDown,
                      onChanged: changeSelectedBrand,
                      value: _currentBrand,
                    ),
                  ],
                ),

//
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Quantity',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'You must enter the product name';
                      }
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Price',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'You must enter the product name';
                      }
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: descriptionController,
                    maxLines: null,
                    decoration:
                        InputDecoration(hintText: 'Enter description here'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'You must Enter description';
                      }
                    },
                  ),
                ),

                FlatButton(
                  color: red,
                  textColor: white,
                  child: Text('Add Product'),
                  onPressed: () {
                    validateAndUpload(productProvider);
                  },
                ),
              ],
            ),
    );
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].data()['category'];
    });
  }

  _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    print(data.length);
    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropDown();
      _currentBrand = brands[0].data()['brand'];
    });
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }

  void changeSelectedSize(String size) {
    if (selectedSizes.contains(size)) {
      setState(() {
        selectedSizes.remove(size);
      });
    } else {
      setState(() {
        selectedSizes.insert(0, size);
      });
    }
  }

  void removeSelectedSize() {
    setState(() {
      selectedSizes = [];
    });
  }

  void _selectImage(Future<File> pickImage) async {
    File tempImg = await pickImage;
    setState(() => _image1 = tempImg);
  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: new Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        _image1,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  void validateAndUpload(ProductProvider productProvider) async {
    if (_formKey.currentState.validate()) {
      setState(() => isLoading = true);
      if (_image1 == null) {
        Fluttertoast.showToast(
            msg: 'You must attach image', backgroundColor: Colors.redAccent);
        return;
      }
      if (selectedSizes.isEmpty) {
        Fluttertoast.showToast(
            msg: 'You must select size', backgroundColor: Colors.redAccent);
        return;
      }
      if (productProvider.selectedColors.isEmpty) {
        Fluttertoast.showToast(
            msg: 'You must select colors', backgroundColor: Colors.redAccent);
        return;
      }

      if (_image1 != null) {
        if (selectedSizes.isNotEmpty) {
          String imageUrl1;

          final FirebaseStorage storage = FirebaseStorage.instance;
          final String picture1 =
              "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task1 =
              storage.ref().child(picture1).putFile(_image1);

          StorageTaskSnapshot snapshot1 =
              await task1.onComplete.then((snapshot) => snapshot);

          task1.onComplete.then((snapshot3) async {
            imageUrl1 = await snapshot1.ref.getDownloadURL();

            productService.uploadProduct({
              "name": productNameController.text.trim(),
              "price": double.parse(priceController.text.trim()),
              "sizes": selectedSizes,
              "colors": colors,
              "picture": imageUrl1,
              "quantity": int.parse(quantityController.text.trim()),
              "description": descriptionController.text.trim(),
              "brand": _currentBrand,
              "category": _currentCategory.toUpperCase(),
              'sale': onSale,
              'featured': featured
            });
            setState(() {
              isLoading = false;
              _image1 = null;
              featured = false;
              onSale = false;
            });
            productNameController.clear();
            descriptionController.clear();
            quantityController.clear();
            priceController.clear();
            _formKey.currentState.reset();
            productProvider.removeAllColors();
            removeSelectedSize();
            Fluttertoast.showToast(msg: "Product added Successfully");
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
//        Fluttertoast.showToast(msg: 'all the images must be provided');
      }
    }
  }
}
