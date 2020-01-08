import 'dart:io';

import 'package:Agenda/ui/contactPage.dart';
import 'package:flutter/material.dart';
import 'package:Agenda/helpers/contacts_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> contacts = List();
  Contacts_helper helper = Contacts_helper();

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Icon(Icons.menu),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          goToContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return contactCard(context, index);
        },
      ),
    );
  }

  Widget contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null
                        ? AssetImage(
                            "images/no-photo.png") //FileImage(File(contacts[index].img))
                        : AssetImage("images/no-photo.png"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "no name",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(contacts[index].email,
                        style: TextStyle(fontSize: 18.0)),
                    Text(contacts[index].phone,
                        style: TextStyle(fontSize: 18.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        showOptions(context, index);
      },
    );
  }

  void showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: (){},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatButton(
                        onPressed: () {},
                        child: Text(
                          "Ligar",
                          style: TextStyle(
                              color: Colors.blueAccent, fontSize: 20.0),
                        )),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          goToContactPage(editContact: contacts[index]);
                        },
                        child: Text(
                          "Editar",
                          style: TextStyle(
                              color: Colors.blueAccent, fontSize: 20.0),
                        )),
                    FlatButton(
                        onPressed: () {
                          helper.deleteContact(index);
                        },
                        child: Text(
                          "Excluir",
                          style: TextStyle(
                              color: Colors.blueAccent, fontSize: 20.0),
                        ))
                  ],
                ),
              );
            },
          );
        });
  }

  void goToContactPage({Contact editContact}) async {
    final returnContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: editContact,
                )));

    if (returnContact != null) {
      if (editContact != null) {
        setState(() {
          helper.updateContact(returnContact);
        });
      } else {
        await helper.saveContact(returnContact);
      }
      getContacts();
    }
  }

  void getContacts() {
    helper.getAllContacts().then((contactsList) {
      setState(() {
        print(contactsList);
        this.contacts = contactsList;
      });
    });
  }
}
