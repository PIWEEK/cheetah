import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';



class Contacts extends StatefulWidget {
  @override
  ContactsState createState() {
    return ContactsState();
  }
}

class ContactsState extends State<Contacts> {
  Future<Iterable<Contact>> _contacts;
  final Set<String> _saved = Set<String>();

  Future<Iterable<Contact>> getContacts() async {
    return ContactsService.getContacts();
  }

  Widget _buildRow(Contact contact) {
    final alreadySaved = _saved.contains(contact.phones.first.value);

    return ListTile(
        title: Text(
            contact.displayName
        ),
        trailing: Icon(
          alreadySaved ? Icons.remove : Icons.add,
          color: null,
        ),
        onTap: () {
          setState(() {
            if (alreadySaved) {
              _saved.remove(contact.phones.first.value);
            } else {
              _saved.add(contact.phones.first.value);
            }
          });
        }
    );
  }

  Widget _buildContacts(List<Contact> contacts) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;

          if (index < contacts.length) {
            return _buildRow(contacts[index]);
          }
        });
  }


  @override
  void initState() {
    super.initState();
    _contacts = getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar invitados'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, _saved.toList());
              }
            );
          },
        ),
      ),
      body: Center(
        child: Container(
          child: FutureBuilder<Iterable<Contact>>(
            future: _contacts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildContacts(
                    snapshot.data.where((i) => i.phones.length != 0).toList()
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return CircularProgressIndicator();
            },
          ),
        )
      ),
    );
  }
}