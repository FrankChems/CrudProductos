import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//IMAGE_PICK
import 'package:image_picker/image_picker.dart';

import 'package:productos_app/providers/product_form_provider.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/ui/inputs_decorations.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //llamamos a nuestra copia del producto
    final productsService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
      //traemos a nuestro validador de promularios
      create: (_) => ProductFormProvider(productsService.selectedProduct),
      //y llamamos anuestro diseño
      child: _ProductSreecBody(productsService: productsService),
    );
  }
}

class _ProductSreecBody extends StatelessWidget {
  const _ProductSreecBody({
    Key? key,
    required this.productsService,
  }) : super(key: key);

  final ProductsService productsService;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Stack(
              children: [
                // enviamos la copia de la imagen del producto
                ProductImage(url: productsService.selectedProduct.picture),
                //los iconos que lleva cada imagen con su tarjeta
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    onPressed: () async {
                      //TODO camara o galería.

                      final picker = new ImagePicker();
                      final PickedFile? pickedFile = await picker.getImage(
                          // source: ImageSource.gallery,
                          source: ImageSource.camera,
                          imageQuality: 100);
                      if (PickedFile == null) {
                        print('NO seleccionó nada');
                        return;
                      }

                      productsService
                          .updateSelectedProductImage(pickedFile!.path);
                    },
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            //parte de abajo de la imagen
            _ProductForm(),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: productsService.isSaving
            ? CircularProgressIndicator(color: Colors.white)
            : Icon(Icons.save_outlined),
        onPressed: productsService.isSaving
            ? null
            : () async {
                if (!productForm.isValidForm()) return;
                // llamamos a nuestro metodo
                final String? imageUrl = await productsService.uploadImage();

                if (imageUrl != null) productForm.product.picture = imageUrl;

                await productsService.saveOrCreateProduct(productForm.product);
              },
      ),
    );
  }
}

class _ProductForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
          //nuestra llave
          key: productForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              TextFormField(
                initialValue: product.name,
                onChanged: (value) => product.name = value,
                validator: (value) {
                  if (value == null || value.length < 1)
                    return 'El nombre es obligatorio';
                },
                decoration: InputsDecorations.authInputDecoration(
                    hintText: 'Nombre del Producto', labelText: 'Nombre'),
              ),
              SizedBox(),
              TextFormField(
                initialValue: '${product.price}',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^(\d+)?\.?\d{0,2}'))
                ],
                onChanged: (value) {
                  if (double.tryParse(value) == null) {
                    product.price = 0;
                  } else {
                    product.price = double.parse(value);
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputsDecorations.authInputDecoration(
                    hintText: '\$150', labelText: 'Precio'),
              ),
              SizedBox(
                height: 30,
              ),
              SwitchListTile.adaptive(
                  title: Text('Disponible'),
                  value: product.available,
                  activeColor: Colors.indigo,
                  onChanged: productForm.updateAvailability),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 5))
        ],
      );
}
