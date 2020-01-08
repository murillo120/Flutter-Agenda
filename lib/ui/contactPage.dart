import 'dart:io';

import 'package:Agenda/helpers/contacts_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact editedContact;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool userEdited = false;

  final focusname = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      editedContact = Contact();
    } else {
      editedContact = Contact.fromMap(widget.contact.toMap());
      nameController.text = editedContact.name;
      emailController.text = editedContact.email;
      phoneController.text = editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: requestPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text(editedContact.name ?? "Novo Contato"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            backgroundColor: Colors.blueAccent,
            onPressed: () {
              if (editedContact.name != null && editedContact.name.isNotEmpty) {
                editedContact.email = emailController.text;
                editedContact.phone = phoneController.text;
                Navigator.pop(context, editedContact);
              } else {
                FocusScope.of(context).requestFocus(focusname);
              }
            },
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    ImagePicker.pickImage(source: ImageSource.camera)
                        .then((onValue) {
                      setState(() {
                        if (onValue == null) {
                          return;
                        } else {
                          editedContact.img = onValue.path;
                        }
                      });
                    });
                  },
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: editedContact.img != null
                            ? FileImage(File(editedContact.img))
                            : AssetImage("images/no-photo.png"),
                            fit: BoxFit.cover
                      ),
                    ),
                  ),
                ),
                textFieldBuilder(nameController, "Name", TextInputType.text,
                    appBarText: appBarText, focus: focusname),
                textFieldBuilder(
                    emailController, "E-mail", TextInputType.emailAddress),
                textFieldBuilder(phoneController, "Phone", TextInputType.phone),
              ],
            ),
          )),
    );
  }

  Widget textFieldBuilder(
      TextEditingController controller, String label, TextInputType type,
      {Function appBarText, FocusNode focus}) {
    return TextField(
      focusNode: focus,
      keyboardType: type,
      controller: controller,
      decoration: InputDecoration(
          labelText: label, labelStyle: TextStyle(color: Colors.blueAccent)),
      style: TextStyle(fontSize: 20.0),
      onChanged: (value) {
        userEdited = true;
        setState(() {
          appBarText(value);
        });
      },
    );
  }

  appBarText(String text) {
    editedContact.name = text;
  }

  Future<bool> requestPop() {
    if (userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("descartar alterações ?"),
              content: Text("Se sair agora, as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
