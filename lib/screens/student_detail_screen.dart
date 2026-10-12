
import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/api_service.dart';

// Monochrome doodle palette
const Color paper = Color(0xFFFAFAF7);
const Color white = Color(0xFFFFFFFF);
const Color ink = Color(0xFF202020);
const Color muted = Color(0xFF777777);
const Color paperLine = Color(0xFFE5E5E0);
const Color softBlack = Color(0xFFF0F0EC);

class StudentDetailScreen extends StatefulWidget {
  final int studentId;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentDetailScreen> createState() =>
      _StudentDetailScreenState();
}

class _StudentDetailScreenState
    extends State<StudentDetailScreen> {
  final ApiService apiService = ApiService();

  Student? student;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadStudent();
  }

  Future<void> loadStudent() async {
    try {
      final result = await apiService.getStudent(
        widget.studentId,
      );

      if (!mounted) return;

      setState(() {
        student = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
        isLoading = false;
      });
    }
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
              child: buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget doodleIcon({
    required IconData icon,
    double size = 25,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: white,
        border: Border.all(
          color: ink,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(14),
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
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        color: white,
        border: Border(
          bottom: BorderSide(
            color: ink,
            width: 2,
          ),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    color: ink,
                    size: 21,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'BACK TO NOTEBOOK',
                    style: TextStyle(
                      color: ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              doodleIcon(
                icon: Icons.menu_book_rounded,
                size: 28,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Details',
                      style: TextStyle(
                        color: ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'A closer look at your student.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: 0.15,
                child: const Icon(
                  Icons.star_outline_rounded,
                  color: ink,
                  size: 32,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: ink,
              ),
              SizedBox(width: 7),
              Text(
                'YOUR STUDENT NOTEBOOK',
                style: TextStyle(
                  color: ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: ink,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Opening your notebook...',
              style: TextStyle(
                color: muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: white,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                doodleIcon(
                  icon: Icons.person_off_outlined,
                  size: 35,
                ),

                const SizedBox(height: 22),

                const Text(
                  'Oops! Not Found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 23),

                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      loadStudent();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text('TRY AGAIN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ink,
                      foregroundColor: white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                        side: const BorderSide(
                          color: ink,
                          width: 2,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (student == null) {
      return const Center(
        child: Text(
          'Student not found.',
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return SingleChildScrollView(
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
              buildProfileCard(),
              const SizedBox(height: 24),
              buildInformationCard(),
              const SizedBox(height: 22),
              const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    color: ink,
                    size: 16,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Every student has a story.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 7),
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: ink,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileCard() {
    final fullName =
        '${student!.firstName} ${student!.lastName}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: white,
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
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  color: softBlack,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ink,
                    width: 2.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: ink,
                  size: 60,
                ),
              ),
              Positioned(
                right: -8,
                top: 0,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: white,
                      border: Border.all(
                        color: ink,
                        width: 1.5,
                      ),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: ink,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 23),

          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ink,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 13),

          Transform.rotate(
            angle: -0.025,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: softBlack,
                border: Border.all(
                  color: ink,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'STUDENT #${student!.id}',
                style: const TextStyle(
                  color: ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            '✦  STUDENT PROFILE  ✦',
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              doodleIcon(
                icon: Icons.description_outlined,
                size: 25,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        color: ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'The important little details.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.draw_outlined,
                color: ink,
                size: 25,
              ),
            ],
          ),

          const SizedBox(height: 25),

          buildInfo(
            icon: Icons.badge_outlined,
            label: 'Student ID',
            value: student!.id.toString(),
          ),

          buildDivider(),

          buildInfo(
            icon: Icons.person_outline_rounded,
            label: 'First Name',
            value: student!.firstName,
          ),

          buildDivider(),

          buildInfo(
            icon: Icons.person_outline_rounded,
            label: 'Last Name',
            value: student!.lastName,
          ),

          buildDivider(),

          buildInfo(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: '${student!.age} years old',
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 17,
      ),
      child: Row(
        children: List.generate(
          30,
          (index) => Expanded(
            child: Container(
              height: 1.2,
              margin: const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              color: index.isEven
                  ? paperLine
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: softBlack,
            border: Border.all(
              color: ink,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: ink,
            size: 23,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                style: const TextStyle(
                  color: ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const Icon(
          Icons.check_circle_outline_rounded,
          color: ink,
          size: 19,
        ),
      ],
    );
  }
}
