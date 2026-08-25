class ProfileVisibilityModel {
  final bool showName;
  final bool showAge;
  final bool showGender;
  final bool showEducation;
  final bool showProfession;
  final bool showLocation;
  final bool showFamily;
  final bool showPhotos;
  final bool showPhone;
  final bool showEmail;
  final bool showExactAddress;
  final bool showAbout;
  final bool showLifestyle;
  final bool showHobbies;
  final bool showMaritalStatus;
  final bool showMotherTongue;
  final bool showHeight;

  ProfileVisibilityModel({
    this.showName = true,
    this.showAge = true,
    this.showGender = true,
    this.showEducation = true,
    this.showProfession = true,
    this.showLocation = true,
    this.showFamily = true,
    this.showPhotos = true,
    this.showPhone = false,
    this.showEmail = false,
    this.showExactAddress = false,
    this.showAbout = true,
    this.showLifestyle = true,
    this.showHobbies = true,
    this.showMaritalStatus = true,
    this.showMotherTongue = true,
    this.showHeight = true,
  });

  factory ProfileVisibilityModel.fromJson(Map<String, dynamic> json) {
    return ProfileVisibilityModel(
      showName: json['show_name'] ?? true,
      showAge: json['show_age'] ?? true,
      showGender: json['show_gender'] ?? true,
      showEducation: json['show_education'] ?? true,
      showProfession: json['show_profession'] ?? true,
      showLocation: json['show_location'] ?? true,
      showFamily: json['show_family'] ?? true,
      showPhotos: json['show_photos'] ?? true,
      showPhone: json['show_phone'] ?? false,
      showEmail: json['show_email'] ?? false,
      showExactAddress: json['show_exact_address'] ?? false,
      showAbout: json['show_about'] ?? true,
      showLifestyle: json['show_lifestyle'] ?? true,
      showHobbies: json['show_hobbies'] ?? true,
      showMaritalStatus: json['show_marital_status'] ?? true,
      showMotherTongue: json['show_mother_tongue'] ?? true,
      showHeight: json['show_height'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_name': showName,
      'show_age': showAge,
      'show_gender': showGender,
      'show_education': showEducation,
      'show_profession': showProfession,
      'show_location': showLocation,
      'show_family': showFamily,
      'show_photos': showPhotos,
      'show_phone': showPhone,
      'show_email': showEmail,
      'show_exact_address': showExactAddress,
      'show_about': showAbout,
      'show_lifestyle': showLifestyle,
      'show_hobbies': showHobbies,
      'show_marital_status': showMaritalStatus,
      'show_mother_tongue': showMotherTongue,
      'show_height': showHeight,
    };
  }

  ProfileVisibilityModel copyWith({
    bool? showName,
    bool? showAge,
    bool? showGender,
    bool? showEducation,
    bool? showProfession,
    bool? showLocation,
    bool? showFamily,
    bool? showPhotos,
    bool? showPhone,
    bool? showEmail,
    bool? showExactAddress,
    bool? showAbout,
    bool? showLifestyle,
    bool? showHobbies,
    bool? showMaritalStatus,
    bool? showMotherTongue,
    bool? showHeight,
  }) {
    return ProfileVisibilityModel(
      showName: showName ?? this.showName,
      showAge: showAge ?? this.showAge,
      showGender: showGender ?? this.showGender,
      showEducation: showEducation ?? this.showEducation,
      showProfession: showProfession ?? this.showProfession,
      showLocation: showLocation ?? this.showLocation,
      showFamily: showFamily ?? this.showFamily,
      showPhotos: showPhotos ?? this.showPhotos,
      showPhone: showPhone ?? this.showPhone,
      showEmail: showEmail ?? this.showEmail,
      showExactAddress: showExactAddress ?? this.showExactAddress,
      showAbout: showAbout ?? this.showAbout,
      showLifestyle: showLifestyle ?? this.showLifestyle,
      showHobbies: showHobbies ?? this.showHobbies,
      showMaritalStatus: showMaritalStatus ?? this.showMaritalStatus,
      showMotherTongue: showMotherTongue ?? this.showMotherTongue,
      showHeight: showHeight ?? this.showHeight,
    );
  }
}
