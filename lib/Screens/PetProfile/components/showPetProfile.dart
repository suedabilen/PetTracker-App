import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For File Upload To Firestore
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker
import 'package:path/path.dart' as Path;

//TODO renkler düzenlenecegi icin ugrasmadım
class updatePetProfile extends StatefulWidget {
  final String docPath;

  const updatePetProfile({Key key, this.docPath}) : super(key: key);

  @override
  _updatePetProfile createState() => _updatePetProfile();
}

class _updatePetProfile extends State<updatePetProfile> {
  final _formKey = GlobalKey<FormState>();
  final dbRef = FirebaseFirestore.instance
      .collection("users")
      .doc("susudeneme")
      .collection("pets");


  File _imageFile;


  String _imageURL ;
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = Path.basename(_imageFile.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('defaults/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) =>
              _imageURL = value + "${DateTime.now().millisecondsSinceEpoch}",
        );
  }

  @override
  Widget build(BuildContext context) {
    var age,breed,name;
    var db = FirebaseFirestore.instance.collection("users").doc("susudeneme")
        .collection("pets").doc(widget.docPath).get().then((value){
       age = value.data()["age"];
       name =value.data()["name"] ;
       breed =value.data()["breed"] ;
      _imageURL = value.data()["image"];
    });


    TextEditingController ageTextController = TextEditingController(text: age);
    TextEditingController nameTextController = TextEditingController(text: name);
    TextEditingController breedTextController = TextEditingController(text:breed );
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Stack(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Container(
                            height: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: _imageFile != null
                                  ? Image.file(_imageFile)
                                  : FlatButton(
                                      color: Colors.deepOrangeAccent,
                                      child: Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                      ),
                                      onPressed: pickImage,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [uploadImageButton(context)],
              ),
              Container(
                margin:
                    const EdgeInsets.only(top: 250, left: 20.0, right: 50.0),
                child: Row(children: <Widget>[
                  Flexible(
                      child: TextField(

                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange),
                        ),
                        labelText: "Pet Name"),
                    maxLines: 1,
                    controller: nameTextController,
                  ))
                ]),
              ),
              Container(
                margin:
                    const EdgeInsets.only(top: 330, left: 20.0, right: 50.0),
                child: Row(children: <Widget>[
                  Flexible(
                      child: TextField(
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange),
                        ),
                        labelText: "Pet Breed"),
                    maxLines: 1,
                    controller: breedTextController,
                  ))
                ]),
              ),
              Container(
                margin:
                    const EdgeInsets.only(top: 410, left: 20.0, right: 50.0),
                child: Row(children: <Widget>[
                  Flexible(
                      child: TextField(
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange),
                        ),
                        labelText: "Pet Age"),
                    maxLines: 1,
                    controller: ageTextController,
                  ))
                ]),
              ),
              Container(
                margin:
                    const EdgeInsets.only(top: 490, left: 20.0, right: 50.0),
                child: Row(children: <Widget>[
                  Flexible(
                      child: RaisedButton(
                          onPressed: () {

                              dbRef.doc(widget.docPath).update({
                                "name": nameTextController.text,
                                "breed": breedTextController.text,
                                "age": ageTextController.text,
                                "image": _imageURL
                              }).then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Successfully Updated!')));
                                ageTextController.clear();
                                nameTextController.clear();
                                breedTextController.clear();
                              });

                          },
                          child: Text("Update",
                              style: TextStyle(
                                fontFamily: "Patua",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              )),
                          color: Colors.deepOrange))
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget uploadImageButton(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.only(top: 170, left: 20.0, right: 20.0),
            decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(10.0)),
            child: FlatButton(
              onPressed: () => uploadImageToFirebase(context),
              child: Text(
                "Update Pet Image",
                style: TextStyle(fontSize: 20, fontFamily: "Patua"),
              ),
            ),
          ),
        ],
      ),
    );
  }

//   @override
//   void dispose() {
//     super.dispose();
//     nameTextController.dispose();
//     ageTextController.dispose();
//     breedTextController.dispose();
//   }
}