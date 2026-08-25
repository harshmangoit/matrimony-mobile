class ChildProfileModel {
  final int id;
  final int parentId;
  final String firstName;
  final String lastName;
  final String gender;
  final String dateOfBirth;
  final int calculatedAge;
  final int heightCm;
  final String maritalStatus;
  final String motherTongue;
  
  final String? highestEducation;
  final String? degree;
  final String? institution;
  
  final String? profession;
  final String? company;
  final String? jobTitle;
  final String? workLocation;
  
  final String? currentCity;
  final String? state;
  final String country;
  final String? hometown;
  final String? exactAddress;
  
  final String? fatherName;
  final String? grandfatherName;
  final String? motherName;
  final String? siblings;
  final int? familyMembersCount;
  final String? familyBackground;
  
  final String? tehsil;
  final String? villageTown;
  final String? postOffice;
  final String? pincode;
  final String? birthTime;
  
  final String? about;
  final String? hobbies;
  final String? lifestyle;
  final String? profilePhoto;
  final String? additionalPhotos;
  final String? phoneNumber;
  final String? email;
  
  final String category;
  final String searchType;
  final String manglikStatus;
  final double? weightKg;
  final String? complexion;
  
  final String? gotraSelf;
  final String? gotraMama;
  final String? gotraPaternalNani;
  final String? gotraMaternalNani;

  final String status;
  final int completionPercentage;
  final DateTime? createdAt;

  ChildProfileModel({
    required this.id,
    required this.parentId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.calculatedAge,
    required this.heightCm,
    required this.maritalStatus,
    required this.motherTongue,
    this.category = 'A',
    this.searchType = 'Engagement',
    this.manglikStatus = 'Normal',
    this.weightKg,
    this.complexion,
    this.gotraSelf,
    this.gotraMama,
    this.gotraPaternalNani,
    this.gotraMaternalNani,
    this.highestEducation,
    this.degree,
    this.institution,
    this.profession,
    this.company,
    this.jobTitle,
    this.workLocation,
    this.currentCity,
    this.state,
    this.country = 'India',
    this.hometown,
    this.exactAddress,
    this.fatherName,
    this.grandfatherName,
    this.motherName,
    this.siblings,
    this.familyMembersCount,
    this.familyBackground,
    this.tehsil,
    this.villageTown,
    this.postOffice,
    this.pincode,
    this.birthTime,
    this.about,
    this.hobbies,
    this.lifestyle,
    this.profilePhoto,
    this.additionalPhotos,
    this.phoneNumber,
    this.email,
    required this.status,
    required this.completionPercentage,
    this.createdAt,
  });

  factory ChildProfileModel.fromJson(Map<String, dynamic> json) {
    return ChildProfileModel(
      id: json['id'],
      parentId: json['parent_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      calculatedAge: json['calculated_age'] ?? 25,
      heightCm: json['height_cm'] ?? 165,
      maritalStatus: json['marital_status'] ?? 'Never Married',
      motherTongue: json['mother_tongue'] ?? 'Hindi',
      category: json['category'] ?? 'A',
      searchType: json['search_type'] ?? 'Engagement',
      manglikStatus: json['manglik_status'] ?? 'Normal',
      weightKg: json['weight_kg'] != null ? double.tryParse(json['weight_kg'].toString()) : null,
      complexion: json['complexion'],
      gotraSelf: json['gotra_self'],
      gotraMama: json['gotra_mama'],
      gotraPaternalNani: json['gotra_paternal_nani'],
      gotraMaternalNani: json['gotra_maternal_nani'],
      highestEducation: json['highest_education'],
      degree: json['degree'],
      institution: json['institution'],
      profession: json['profession'],
      company: json['company'],
      jobTitle: json['job_title'],
      workLocation: json['work_location'],
      currentCity: json['current_city'],
      state: json['state'],
      country: json['country'] ?? 'India',
      hometown: json['hometown'],
      exactAddress: json['exact_address'],
      fatherName: json['father_name'],
      grandfatherName: json['grandfather_name'],
      motherName: json['mother_name'],
      siblings: json['siblings'],
      familyMembersCount: json['family_members_count'] != null ? int.tryParse(json['family_members_count'].toString()) : null,
      familyBackground: json['family_background'],
      tehsil: json['tehsil'],
      villageTown: json['village_town'],
      postOffice: json['post_office'],
      pincode: json['pincode'],
      birthTime: json['birth_time'],
      about: json['about'],
      hobbies: json['hobbies'],
      lifestyle: json['lifestyle'],
      profilePhoto: json['profile_photo'],
      additionalPhotos: json['additional_photos'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      status: json['status'] ?? 'ACTIVE',
      completionPercentage: json['completion_percentage'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
