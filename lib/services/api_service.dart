
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/student.dart';

class ApiService {

  static const String baseUrl =
      'http://localhost/php_api_sample/api';

  Future<List<Student>> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load students.\n'
          'HTTP ${response.statusCode}\n'
          '${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map(
              (json) => Student.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      }

      if (decoded is Map &&
          decoded['data'] is List) {
        return (decoded['data'] as List)
            .map(
              (json) => Student.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      }

      throw Exception(
        'Invalid student list.\n'
        '${response.body}',
      );
    } catch (e) {
      if (e is Exception) {
        throw e;
      }

      throw Exception(
        'Can\'t connect to the student API: $e',
      );
    }
  }


  Future<Student> getStudent(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 404) {
        throw Exception(
          'Student with ID $id was not found.',
        );
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load student.\n'
          'HTTP ${response.statusCode}\n'
          '${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map &&
          decoded['data'] is Map) {
        return Student.fromJson(
          Map<String, dynamic>.from(
            decoded['data'],
          ),
        );
      }

      if (decoded is Map) {
        return Student.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }

      throw Exception(
        'Invalid student response.',
      );
    } catch (e) {
      if (e is Exception) {
        throw e;
      }

      throw Exception(
        'Unable to fetch student: $e',
      );
    }
  }

  Future<void> addStudent({
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/student'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'age': age,
        }),
      );


      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return;
      }

      String message =
          'Failed to add student.\n'
          'HTTP ${response.statusCode}';

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map) {
            if (decoded['message'] != null) {
              message +=
                  '\n${decoded['message']}';
            }

            if (decoded['error'] != null) {
              message +=
                  '\n${decoded['error']}';
            }

            if (decoded['errors'] != null) {
              message +=
                  '\n${decoded['errors']}';
            }
          }
        } catch (_) {
          message +=
              '\n${response.body}';
        }
      }

      throw Exception(message);
    } catch (e) {
      if (e is Exception) {
        throw e;
      }

      throw Exception(
        'Unable to add student: $e',
      );
    }
  }

  Future<void> updateStudent({
    required int id,
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/student/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'age': age,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        return;
      }


      if (response.statusCode == 404) {
        throw Exception(
          'Student with ID $id was not found.',
        );
      }

      String message =
          'Failed to update student.\n'
          'HTTP ${response.statusCode}';

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map) {
            if (decoded['message'] != null) {
              message +=
                  '\n${decoded['message']}';
            } else if (decoded['error'] != null) {
              message +=
                  '\n${decoded['error']}';
            } else if (decoded['errors'] != null) {
              message +=
                  '\n${decoded['errors']}';
            }
          }
        } catch (_) {
          message +=
              '\n${response.body}';
        }
      }

      throw Exception(message);
    } catch (e) {
      if (e is Exception) {
        throw e;
      }

      throw Exception(
        'Unable to update student: $e',
      );
    }
  }


  Future<void> deleteStudent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/student/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        return;
      }

      if (response.statusCode == 404) {
        throw Exception(
          'Student with ID $id was not found.',
        );
      }

      String message =
          'Failed to delete student.\n'
          'HTTP ${response.statusCode}';

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map) {
            if (decoded['message'] != null) {
              message +=
                  '\n${decoded['message']}';
            } else if (decoded['error'] != null) {
              message +=
                  '\n${decoded['error']}';
            }
          }
        } catch (_) {
          message +=
              '\n${response.body}';
        }
      }

      throw Exception(message);
    } catch (e) {
      if (e is Exception) {
        throw e;
      }

      throw Exception(
        'Unable to delete student: $e',
      );
    }
  }
}
