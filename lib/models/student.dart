class Student {
  final int id;
  final String firstName;
  final String lastName;
  final int age;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
  });

  factory Student.fromJson(Map<String, dynamic> json){
    return Student(
      id: int.parse(json['id'].toString()),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      age: int.parse(json['age'].toString()),
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
    };
  }
}