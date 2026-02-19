class Beneficiary {
  int? id;
  String firstName;
  String secondName;
  String nationalId;
  String contact;
  String? email;

  Beneficiary({
    this.id,
    required this.firstName,
    required this.secondName,
    required this.nationalId,
    required this.contact,
    this.email,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) => Beneficiary(
        id: json['id'],
        firstName: json['first_name'],
        secondName: json['second_name'],
        nationalId: json['national_id'].toString(),
        contact: json['contact'],
        email: json['email'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'first_name': firstName,
        'second_name': secondName,
        'national_id': nationalId,
        'contact': contact,
        'email': email,
      };
}
