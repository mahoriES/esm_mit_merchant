import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with AfterLayoutMixin<ContactsPage> {
  final _formKey = GlobalKey<FormState>();
  List<Contact> contacts = List<Contact>();
  @override
  void afterFirstLayout(BuildContext context) {
    getContacts();
  }

  getContacts() async {
    var isGranted = await getPermissions();
    if (isGranted) {
      Iterable<Contact> contactsResult = await ContactsService.getContacts();
      setState(() {
        this.contacts = contactsResult.toList();
      });
    }
  }

  Future<bool> getPermissions() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission.value != PermissionStatus.granted.value) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
    }
    return true;
  }

  Future<bool> _onWillPop() async {
    var contacts = List<Contact>();
    Navigator.of(context).pop(contacts);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.dehaze),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text("Pick contacts"),
      ),
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: ListView.builder(
          itemCount: this.contacts.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              onChanged: (isSelected) {},
              value: false,
              title: Text(this.contacts[index].displayName ?? ''),
              subtitle: Text(this.contacts[index].phones.length > 0
                  ? this.contacts[index].phones.toList()[0].value
                  : ''),
            );
          },
        ),
      ),
      floatingActionButton: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 25,
        ),
        onPressed: () {},
        child: Container(
          child: Text(
            "Select contacts",
            style: Theme.of(context).textTheme.subhead.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
