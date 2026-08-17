class MatchItemModel {
  final int matchId;
  final int childProfileId;
  final int matchScore;
  final Map<String, dynamic> breakdown;
  final Map<String, dynamic> visibleProfile;

  MatchItemModel({
    required this.matchId,
    required this.childProfileId,
    required this.matchScore,
    required this.breakdown,
    required this.visibleProfile,
  });

  factory MatchItemModel.fromJson(Map<String, dynamic> json) {
    return MatchItemModel(
      matchId: json['match_id'] ?? json['child_profile_id'] ?? 0,
      childProfileId: json['child_profile_id'] ?? 0,
      matchScore: json['match_score'] ?? 0,
      breakdown: Map<String, dynamic>.from(json['breakdown'] ?? {}),
      visibleProfile: Map<String, dynamic>.from(json['visible_profile'] ?? {}),
    );
  }

  // Convenient dynamic getters for UI rendering
  String get displayName {
    if (visibleProfile.containsKey('first_name')) {
      final fname = visibleProfile['first_name'] ?? '';
      final lname = visibleProfile['last_name'] ?? '';
      return "$fname $lname".trim();
    }
    return "Verified Profile";
  }

  String? get ageAndGender {
    final age = visibleProfile['calculated_age'];
    final gender = visibleProfile['gender'];
    if (age != null && gender != null) {
      return "$age Yrs, $gender";
    } else if (age != null) {
      return "$age Yrs";
    } else if (gender != null) {
      return "$gender";
    }
    return null;
  }

  String? get location {
    final city = visibleProfile['current_city'];
    final state = visibleProfile['state'];
    if (city != null && state != null) {
      return "$city, $state";
    }
    return city ?? state ?? visibleProfile['country'];
  }

  String? get profession => visibleProfile['profession'];
  String? get education => visibleProfile['highest_education'] ?? visibleProfile['degree'];
  String? get photoUrl => visibleProfile['profile_photo'];
}
