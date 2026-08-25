class ParentModel {
  final int id;
  final String mobileNumber;
  final String fullName;
  final String? email;
  final String relationshipToChild;
  final String status;
  final String subscriptionStatus;
  final int maxProfilesAllowed;

  ParentModel({
    required this.id,
    required this.mobileNumber,
    required this.fullName,
    this.email,
    required this.relationshipToChild,
    required this.status,
    required this.subscriptionStatus,
    this.maxProfilesAllowed = 1,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id'],
      mobileNumber: json['mobile_number'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'],
      relationshipToChild: json['relationship_to_child'] ?? 'Parent',
      status: json['status'] ?? 'ACTIVE',
      subscriptionStatus: json['subscription_status'] ?? 'FREE',
      maxProfilesAllowed: json['max_profiles_allowed'] ?? 1,
    );
  }
}
