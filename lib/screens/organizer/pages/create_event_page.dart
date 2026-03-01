import 'package:flutter/material.dart';
import '../../../services/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:html' as html;

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final title = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();
  final ticketLimit = TextEditingController();

  DateTime? selectedDate;
  html.File? imageFile;
  bool isLoading = false;

  Future<void> pickImage() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      setState(() {
        imageFile = file;
      });
    });
  }

  Future<void> createEvent() async {
    print("🚀 Create button clicked");

    if (!_formKey.currentState!.validate()) {
      print("❌ Form validation failed");
      return;
    }

    if (imageFile == null) {
      print("❌ Image not selected");
    }

    if (selectedDate == null) {
      print("❌ Date not selected");
    }

    if (imageFile == null || selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select image and date")));
      return;
    }

    try {
      setState(() => isLoading = true);
      print("⏳ Loading started");

      final uid = FirebaseAuth.instance.currentUser!.uid;
      print("👤 Organizer UID: $uid");

      print("📤 Uploading image...");
      final imageUrl = await EventService().uploadImage(imageFile!);
      print("✅ Image uploaded: $imageUrl");

      print("📝 Creating Firestore document...");
      await EventService().createEvent(
        title: title.text.trim(),
        description: description.text.trim(),
        date: selectedDate!.toIso8601String(),
        price: double.parse(price.text.trim()),
        ticketLimit: int.parse(ticketLimit.text.trim()),
        imageUrl: imageUrl,
        organizerId: uid,
      );

      print("🎉 Firestore document created");

      setState(() => isLoading = false);

      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(
              content: Text("Event Created Successfully 🎉"),
            ),
      );

      title.clear();
      description.clear();
      price.clear();
      ticketLimit.clear();

      setState(() {
        selectedDate = null;
        imageFile = null;
      });
    } catch (e, stack) {
      setState(() => isLoading = false);

      print("🔥 ERROR OCCURRED:");
      print(e);
      print(stack);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Event",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            TextFormField(
              controller: title,
              validator: (v) => v!.isEmpty ? "Enter title" : null,
              decoration: const InputDecoration(
                labelText: "Event Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: description,
              validator: (v) => v!.isEmpty ? "Enter description" : null,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: price,
                    validator: (v) => v!.isEmpty ? "Enter price" : null,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Price",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: ticketLimit,
                    validator: (v) => v!.isEmpty ? "Enter ticket limit" : null,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Ticket Limit",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                    );

                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate == null
                        ? "Select Date"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Upload Image"),
                ),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : createEvent,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                  backgroundColor: Colors.black,
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Create Event"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
