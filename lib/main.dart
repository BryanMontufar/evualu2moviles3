import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfileForm(),
    );
  }
}

class ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _imagePath;
  String? _imageError;

  void _pickImage() async {
    _imageError = null; // Reiniciar el error al intentar seleccionar una imagen
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'], // Limitar a imágenes
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      String extension = filePath.split('.').last.toLowerCase();

      if (['jpg', 'jpeg', 'png'].contains(extension)) {
        setState(() {
          _imagePath = filePath;
          _imageError = null;
        });
      } else {
        setState(() {
          _imageError = 'Please select a valid image file (jpg, jpeg, png)';
        });
      }
    }
  }

  void _previewImage(BuildContext context) {
    if (_imagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imagePath: _imagePath!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _imagePath != null ? _previewImage(context) : _pickImage();
                },
                child: Hero(
                  tag: 'profileImage',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imagePath != null
                        ? FileImage(File(_imagePath!))
                        : null,
                    child: _imagePath == null
                        ? Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
              ),
              if (_imageError != null) // Mostrar error si no es imagen válida
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _imageError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_imagePath == null) {
                      setState(() {
                        _imageError = 'Please select a profile image';
                      });
                    } else {
                      _formKey.currentState!.save();
                      // Aquí puedes manejar el envío del formulario o las acciones adicionales
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile submitted successfully')),
                      );
                    }
                  }
                },
                child: Text('Grabar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  ImagePreviewScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Preview'),
      ),
      body: Center(
        child: Hero(
          tag: 'profileImage',
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }
}
