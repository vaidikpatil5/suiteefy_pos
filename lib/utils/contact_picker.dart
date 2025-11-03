import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';

Future<Map<String, String>?> pickContact(BuildContext context) async {
  // Ask for permission first
  if (await FlutterContacts.requestPermission()) {
    final contact = await FlutterContacts.openExternalPick();

    String sanitizePhoneNumber(String input) {
      // 1. Remove all non-digit characters
      String digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');

      // 2. If it starts with '91' and length > 10, remove the country code
      if (digitsOnly.length > 10 && digitsOnly.startsWith('91')) {
        digitsOnly = digitsOnly.substring(digitsOnly.length - 10);
      }

      // 3. If still longer than 10 digits, take last 10
      if (digitsOnly.length > 10) {
        digitsOnly = digitsOnly.substring(digitsOnly.length - 10);
      }

      return digitsOnly;
    }

    if (contact != null && contact.phones.isNotEmpty) {
      final cleanedPhone = sanitizePhoneNumber(contact.phones.first.number);
      if (cleanedPhone.length == 10) {
        return {'name': contact.displayName, 'phone': cleanedPhone};
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('plz enter no manually')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected contact has no phone number')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permission to access contacts denied')),
    );
  }
  return null;
}
