
import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/api_service.dart';


 // Black-and-white notebook palette
const Color paper = Color(0xFFF8F8F8);
const Color ink = Color(0xFF171717);
const Color muted = Color(0xFF666666);
const Color pink = Color(0xFFE0E0E0);
const Color yellow = Color(0xFFFFFFFF);
const Color mint = Color(0xFFD5D5D5);
const Color blue = Color(0xFFF0F0F0);
const Color lavender = Color(0xFFC8C8C8);
const Color paperLine = Color(0xFFDADADA);


class StudentFormScreen extends StatefulWidget {
  final Student? student;

  const StudentFormScreen({
    super.key,
    this.student,
  });

  bool get isEditing => student != null;

  @override
  State<StudentFormScreen> createState() =>
      _StudentFormScreenState();
}

class _StudentFormScreenState
    extends State<StudentFormScreen> {
  final ApiService apiService = ApiService();
  final formKey = GlobalKey<FormState>();

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController ageController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController(
      text: widget.student?.firstName ?? '',
    );

    lastNameController = TextEditingController(
      text: widget.student?.lastName ?? '',
    );

    ageController = TextEditingController(
      text: widget.student?.age.toString() ?? '',
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> saveStudent() async {
    if (isSaving) return;

    if (!formKey.currentState!.validate()) return;

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final age = int.tryParse(ageController.text.trim());

    if (age == null) {
      showMessage(
        'Please enter a valid age.',
        isError: true,
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      if (widget.isEditing) {
        await apiService.updateStudent(
          id: widget.student!.id,
          firstName: firstName,
          lastName: lastName,
          age: age,
        );
      } else {
        await apiService.addStudent(
          firstName: firstName,
          lastName: lastName,
          age: age,
        );
      }

      if (!mounted) return;

      FocusScope.of(context).unfocus();

      showMessage(
        widget.isEditing
            ? 'Student updated successfully! ✨'
            : 'Student added successfully! 🎉',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final message = e
          .toString()
          .replaceFirst('Exception: ', '');

      showMessage(
        'Failed to save student:\n$message',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isError ? pink : mint,
              width: 2,
            ),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
                color: isError ? pink : mint,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  String? validateFirstName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'First name is required.';
    }

    if (name.length < 2) {
      return 'Use at least 2 characters.';
    }

    return null;
  }

  String? validateLastName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Last name is required.';
    }

    if (name.length < 2) {
      return 'Use at least 2 characters.';
    }

    return null;
  }

  String? validateAge(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Age is required.';
    }

    final age = int.tryParse(text);

    if (age == null) {
      return 'Age must be a valid number.';
    }

    if (age < 1 || age > 120) {
      return 'Age must be between 1 and 120.';
    }

    return null;
  }

  Widget doodleIcon({
    required IconData icon,
    required Color color,
    double size = 25,
  }) {
    return Transform.rotate(
      angle: -0.08,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: ink,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: ink,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: ink,
          size: size,
        ),
      ),
    );
  }

  Widget buildHeader() {
    final isEditing = widget.isEditing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        25,
      ),
      decoration: const BoxDecoration(
        color: yellow,
        border: Border(
          bottom: BorderSide(
            color: ink,
            width: 2,
          ),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: isSaving
                ? null
                : () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back_rounded,
                    color: ink,
                    size: 21,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'BACK TO NOTEBOOK',
                    style: TextStyle(
                      color: ink.withOpacity(
                        isSaving ? 0.4 : 1,
                      ),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              doodleIcon(
                icon: isEditing
                    ? Icons.edit_note_rounded
                    : Icons.person_add_alt_1_rounded,
                color: pink,
                size: 29,
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing
                          ? 'Edit Student ✏️'
                          : 'New Student! ✨',
                      style: const TextStyle(
                        color: ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isEditing
                          ? 'Give their details a little update.'
                          : 'Let’s add someone to our little campus!',
                      style: const TextStyle(
                        color: ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 16,
                color: ink,
              ),
              const SizedBox(width: 7),
              Text(
                isEditing
                    ? 'YOUR STUDENT, YOUR NOTES'
                    : 'EVERY STUDENT HAS A STORY',
                style: const TextStyle(
                  color: ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required Color accent,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: ink,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          enabled: !isSaving,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: const TextStyle(
            color: ink,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: muted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(
                icon,
                color: ink,
                size: 21,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
            ),
            filled: true,
            fillColor: accent.withOpacity(0.42),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: ink,
                width: 1.7,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: ink,
                width: 1.7,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: ink,
                width: 2.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFD9485F),
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFD9485F),
                width: 2.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFormCard() {
    final isEditing = widget.isEditing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: ink,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: ink,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                doodleIcon(
                  icon: Icons.menu_book_rounded,
                  color: mint,
                  size: 24,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Details',
                        style: TextStyle(
                          color: ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Fill in the blanks below.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.rotate(
                  angle: 0.15,
                  child: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF0B82F),
                    size: 30,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            buildTextField(
              controller: firstNameController,
              label: 'First Name',
              hint: 'e.g. Alex',
              icon: Icons.face_rounded,
              validator: validateFirstName,
              accent: pink,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 20),

            buildTextField(
              controller: lastNameController,
              label: 'Last Name',
              hint: 'e.g. Santos',
              icon: Icons.badge_outlined,
              validator: validateLastName,
              accent: blue,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 20),

            buildTextField(
              controller: ageController,
              label: 'Age',
              hint: 'Enter age in years',
              icon: Icons.cake_rounded,
              validator: validateAge,
              accent: lavender,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 23),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: yellow.withOpacity(0.45),
                border: Border.all(
                  color: ink,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: ink,
                    size: 21,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Double-check the details before saving your student record!',
                      style: TextStyle(
                        color: ink,
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mint,
                  foregroundColor: ink,
                  disabledBackgroundColor:
                      mint.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(
                      color: ink,
                      width: 2,
                    ),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          color: ink,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing
                                ? Icons.save_rounded
                                : Icons.person_add_alt_1_rounded,
                            size: 21,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            isEditing
                                ? 'SAVE CHANGES'
                                : 'ADD STUDENT',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 19,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  25,
                  20,
                  35,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 560,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              '✦',
                              style: TextStyle(
                                color: Color(0xFFE8A52E),
                                fontSize: 23,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'YOUR LITTLE NOTEBOOK',
                                style: TextStyle(
                                  color: ink,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            Transform.rotate(
                              angle: 0.15,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: pink,
                                  border: Border.all(
                                    color: ink,
                                    width: 1.5,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.isEditing
                                      ? 'EDIT MODE'
                                      : 'NEW ENTRY',
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 17),

                        buildFormCard(),

                        const SizedBox(height: 22),

                        const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 15,
                              color: Color(0xFFE98FA2),
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Made with a little doodle magic',
                              style: TextStyle(
                                color: muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 7),
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 15,
                              color: Color(0xFFE8B83F),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
