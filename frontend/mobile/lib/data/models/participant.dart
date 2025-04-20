class ParticipantModel {
  const ParticipantModel({required this.id, required this.username,required this.firstName,required this.lastName,required this.phone});
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String phone;
  factory ParticipantModel.fromJson(Map<String, dynamic> json){
    return ParticipantModel(
      firstName: json['first_name'] ?? 'Jon', 
      id: json['id'], 
      lastName: json['last_name'] ?? 'DOE', 
      phone: json['phone'] ?? '', 
      username: json['username']
    );
  }

  @override
  String toString() => '$lastName $firstName ($username)';
}