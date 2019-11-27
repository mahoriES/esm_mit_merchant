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
  List<FoContact> contacts = List<FoContact>();
  bool isPermissionGranted = false;
  int permissionDeniedCount = 0;

  int get numberOfSelectedContacts =>
      this.contacts.where((contact) => contact.isSelected).length;

  @override
  void afterFirstLayout(BuildContext context) {
    getContacts();
  }

  getContacts() async {
    var isGranted = await getPermissions();
    setState(() {
      this.isPermissionGranted = isGranted;
      if (!isGranted) {
        permissionDeniedCount++;
      }
    });
    if (isGranted) {
      Iterable<Contact> contactsResult =
          await ContactsService.getContacts(withThumbnails: false);
      setState(() {
        this.contacts = contactsResult
            .map((contact) => FoContact.fromContact(contact))
            .where((contact) {
          if (contact.phoneNumber != null && contact.phoneNumber != '') {
            return true;
          }
          return false;
        }).toList();
      });
    }
  }

  Future<bool> getPermissions() async {
    bool isGranted = false;
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    isGranted = permission.value == PermissionStatus.granted.value;
    if (!isGranted) {
      bool shouldShowPermissionDialog = await PermissionHandler()
          .shouldShowRequestPermissionRationale(PermissionGroup.contacts);
      if (shouldShowPermissionDialog) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.contacts]);
        isGranted = permissions[PermissionGroup.contacts]?.value ==
            PermissionStatus.granted.value;
      } else if (permissionDeniedCount > 0) {
        await PermissionHandler().openAppSettings();
        Navigator.of(context).pop(List<Contact>());
      }
    }
    return isGranted;
  }

  selectContactWithIndex(bool isSelected, index) {
    setState(() {
      this.contacts[index].isSelected = isSelected;
    });
  }

  Future<bool> _onWillPop() async {
    var contacts = List<FoContact>();
    Navigator.of(context).pop(contacts);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select contacts"),
      ),
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: isPermissionGranted
            ? ListView.builder(
                itemCount: this.contacts.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    onChanged: (isSelected) {
                      selectContactWithIndex(isSelected, index);
                    },
                    value: this.contacts[index].isSelected,
                    secondary: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        height: double.infinity,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(this.contacts[index].name ?? ''),
                    subtitle: Text(this.contacts[index].phoneNumber ?? ''),
                  );
                },
              )
            : permissionNotGrantedWidget(context),
      ),
      floatingActionButton: Visibility(
        visible: numberOfSelectedContacts > 0,
        child: RaisedButton(
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
              'Select contacts ($numberOfSelectedContacts)',
              style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  permissionNotGrantedWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Permission not Granted'),
        RaisedButton(
          onPressed: this.getPermissions,
          child: Text('Give permissions'),
        )
      ],
    );
  }
}

class FoContact {
  String name;
  String phoneNumber;
  Contact contact;
  bool isSelected = false;
  FoContact.fromContact(Contact contact) {
    this.name = contact.givenName;
    if (contact.phones.length > 0) {
      this.phoneNumber = contact.phones.toList()[0].value;
    }
  }
}
