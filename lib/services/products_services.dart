//este archivo se encargará de los Posts

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:productos_app/models/models.dart';

import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  final String _baseUrl = 'flutter-varios-80d30-default-rtdb.firebaseio.com';

  final List<Product> products = [];
  //traemos la información del producto
  late Product selectedProduct;

  File? newPictureFile;

  bool isLoading = true;
  bool isSaving = false;

  //cuando ProducsService sea llamado, se ejecutara el constructor ProductsService()
  ProductsService() {
    this.loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    //para recrear la pantalla de carga
    this.isLoading = true;
    notifyListeners();

    //'products.json' es el nombre del archivo que sacamos de firebase
    //esto es la peticion
    final url = Uri.https(_baseUrl, 'products.json');
    //obtiene la respuesta
    final resp = await http.get(url);

    // lo comvertimos en un mapa la informacion
    final Map<String, dynamic> productsMap = json.decode(resp.body);

    // print(productMap);

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      //ahora lo agregamos a nuestro listado
      this.products.add(tempProduct);
    });

    this.isLoading = false;
    notifyListeners();

    // print(this.products[0].name);

    return this.products;
  }

  //crear o actualizar
  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.id == null) {
      //se debe crear
      await this.createProduct(product);
    } else {
      //actualizar
      await this.updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    //el body es el producto en su forma de json
    final resp = await http.put(url, body: product.toJson());
    final decodedData = resp.body;

    //TODO actualizar el listado
    final index =
        this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    //el body es el producto en su forma de json
    final resp = await http.post(url, body: product.toJson());
    final decodedData = json.decode(resp.body);

    // this.products.add(product);
    product.id = decodedData['name'];
    this.products.add(product);

    return '';
  }

  // cambiar imagen tomada del usuario
  void updateSelectedProductImage(String path) {
    this.selectedProduct.picture = path;
    this.newPictureFile = File.fromUri(Uri(path: path));
    notifyListeners();
  }

// subir la imagen a la plataforma
  Future<String?> uploadImage() async {
    if (this.newPictureFile == null) return null;
    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse(
      // link obtenido del postman y el uso de la pagina cloudinari 
        'https://api.cloudinary.com/v1_1/diovifmob/image/upload?upload_preset=dvvavrmk');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salió mal');
      print(resp.body);
      return null;
    }

    this.newPictureFile = null;

    final decodedData = json.decode(resp.body);
    return decodedData['secure_url'];
  }
}
