import 'package:equatable/equatable.dart';

/// GLP-1 약물 정보 엔티티
///
/// DB medications 마스터 테이블에서 조회되는 약물 정보입니다.
/// 앱 배포 없이 새 약물을 추가할 수 있습니다.
///
/// 사용 예시:
/// ```dart
/// final medications = await ref.read(activeMedicationsProvider.future);
/// final wegovy = medications.firstWhere((m) => m.id == 'wegovy');
/// print(wegovy.displayName); // "Wegovy (세마글루타이드)"
/// ```
class Medication extends Equatable {
  final String id;
  final String nameKo;
  final String nameEn;
  final String? genericName;
  final String? manufacturer;
  final List<double> availableDoses;
  final double? recommendedStartDose;
  final String doseUnit;
  final int cycleDays;
  final bool isActive;
  final int displayOrder;
  final DateTime createdAt;

  const Medication({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    this.genericName,
    this.manufacturer,
    required this.availableDoses,
    this.recommendedStartDose,
    this.doseUnit = 'mg',
    this.cycleDays = 7,
    this.isActive = true,
    required this.displayOrder,
    required this.createdAt,
  });

  /// 기존 dosage_plans.medication_name과 호환되는 표시명 (저장/매칭용)
  ///
  /// 형식: "Wegovy (세마글루타이드)"
  /// 기존 MedicationTemplate.displayName과 동일한 형식을 유지합니다.
  /// UI 표시에는 [localizedDisplayName]을 사용하세요.
  String get displayName {
    if (genericName != null && genericName!.isNotEmpty) {
      return '$nameEn ($genericName)';
    }
    return nameEn;
  }

  /// 로케일에 따른 표시명 (UI 표시용)
  ///
  /// - 'ko': "마운자로 (티르제파타이드)"
  /// - 'en': "Mounjaro (티르제파타이드)"
  String localizedDisplayName(String languageCode) {
    final name = languageCode == 'ko' ? nameKo : nameEn;
    if (genericName != null && genericName!.isNotEmpty) {
      return '$name ($genericName)';
    }
    return name;
  }

  /// 권장 시작 용량 (없으면 첫 번째 용량, 빈 배열이면 0)
  double get startDose {
    if (recommendedStartDose != null) return recommendedStartDose!;
    if (availableDoses.isEmpty) return 0.0;
    return availableDoses.first;
  }

  /// 용량이 유효한지 확인
  bool isValidDose(double dose) => availableDoses.contains(dose);

  /// displayName으로 약물 찾기 (fallback 포함)
  ///
  /// 1차: displayName 정확 매칭 (영문 형식)
  /// 2차: 한글 displayName 형식 매칭
  /// 3차: nameKo로 매칭
  /// 4차: nameEn으로 매칭 (case-insensitive)
  static Medication? findByDisplayName(
    List<Medication> medications,
    String displayName,
  ) {
    // 1차: displayName 정확 매칭 (영문 형식)
    final exact = medications.where((m) => m.displayName == displayName).firstOrNull;
    if (exact != null) return exact;

    // 2차: 한글 displayName 형식 매칭
    final koExact = medications.where((m) => m.localizedDisplayName('ko') == displayName).firstOrNull;
    if (koExact != null) return koExact;

    final namePart = displayName.split(' (').first;

    // 3차: nameKo로 매칭
    final byNameKo = medications.where((m) => m.nameKo == namePart).firstOrNull;
    if (byNameKo != null) return byNameKo;

    // 4차: nameEn으로 매칭 (case-insensitive)
    return medications
        .where((m) => m.nameEn.toLowerCase() == namePart.toLowerCase())
        .firstOrNull;
  }

  Medication copyWith({
    String? id,
    String? nameKo,
    String? nameEn,
    String? genericName,
    String? manufacturer,
    List<double>? availableDoses,
    double? recommendedStartDose,
    String? doseUnit,
    int? cycleDays,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return Medication(
      id: id ?? this.id,
      nameKo: nameKo ?? this.nameKo,
      nameEn: nameEn ?? this.nameEn,
      genericName: genericName ?? this.genericName,
      manufacturer: manufacturer ?? this.manufacturer,
      availableDoses: availableDoses ?? this.availableDoses,
      recommendedStartDose: recommendedStartDose ?? this.recommendedStartDose,
      doseUnit: doseUnit ?? this.doseUnit,
      cycleDays: cycleDays ?? this.cycleDays,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nameKo,
        nameEn,
        genericName,
        manufacturer,
        availableDoses,
        recommendedStartDose,
        doseUnit,
        cycleDays,
        isActive,
        displayOrder,
        createdAt,
      ];

  @override
  String toString() => 'Medication(id: $id, displayName: $displayName)';
}
