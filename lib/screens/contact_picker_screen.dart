// import 'package:flutter/material.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';

// class ContactPickerScreen extends StatefulWidget {
//   const ContactPickerScreen({super.key});

//   @override
//   State<ContactPickerScreen> createState() => _ContactPickerScreenState();
// }

// class _ContactPickerScreenState extends State<ContactPickerScreen> {
//   List<Contact>? _contacts;
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchContacts();
//   }

//   Future<void> _fetchContacts() async {
//     setState(() => _loading = true);

//     if (await FlutterContacts.requestPermission(readonly: true)) {
//       final contacts = await FlutterContacts.getContacts(
//         withProperties: true,
//         withPhoto: false,
//       );
//       setState(() {
//         _contacts = contacts;
//         _loading = false;
//       });
//     } else {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Permission denied to read contacts")),
//       );
//     }
//   }

//   void _selectContact(Contact contact) async {
//     final fullContact = await FlutterContacts.getContact(contact.id);
//     Navigator.pop(context, {
//       'name': fullContact?.displayName ?? '',
//       'phone': fullContact?.phones.isNotEmpty == true
//           ? fullContact?.phones.first.number
//           : '',
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Contact'),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _contacts == null
//               ? const Center(child: Text('No contacts found'))
//               : ListView.builder(
//                   itemCount: _contacts!.length,
//                   itemBuilder: (context, index) {
//                     final contact = _contacts![index];
//                     final phone = contact.phones.isNotEmpty
//                         ? contact.phones.first.number
//                         : "No number";

//                     return ListTile(
//                       leading: CircleAvatar(
//                         child: Text(contact.displayName.isNotEmpty
//                             ? contact.displayName[0]
//                             : '?'),
//                       ),
//                       title: Text(contact.displayName),
//                       subtitle: Text(phone),
//                       onTap: () => _selectContact(contact),
//                     );
//                   },
//                 ),
//     );
//   }
// }
