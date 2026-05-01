import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AppPalette {
  static const Color primary = Color(0xFF37474F);
  static const Color secondary = Color(0xFFFF8A65);
  static const Color accent = Color(0xFFFF5252);
  static const Color background = Color(0xFFFFEBEE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
  static const Color atlanticSand = border;
  static const Color sidebar = Color(0xFF37474F);
  static const Color sidebarBorder = Color(0xFF455A64);
  static const Color sidebarSelected = Color(0xFFFF8A65);
  static const Color sidebarIcon = Color(0xFFFFEBEE);
  static const Color sidebarIconActive = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF37474F);
  static const Color textMuted = Color(0xFF455A64);
  static const Color chart = Color(0xFFFF8A65);
}

void main() {
  runApp(const EyecarePilotApp());
}

class EyecarePilotApp extends StatefulWidget {
  const EyecarePilotApp({super.key});

  @override
  State<EyecarePilotApp> createState() => _EyecarePilotAppState();
}

class _EyecarePilotAppState extends State<EyecarePilotApp> {
  ThemeMode themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppPalette.primary),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Shokane Eyecare Pilot',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: base.copyWith(
        scaffoldBackgroundColor: AppPalette.background,
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppPalette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppPalette.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppPalette.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
        ),
        textTheme: base.textTheme.copyWith(
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A1625),
      ),
      home: EyecarePilotScreen(
        isDarkMode: themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

enum ServiceType { consultation, diagnosticAssessment, certificateAssessment }

enum BookingStatus { pending, checkedIn, completed, noShow }

enum ClaimStatus { draft, submitted, denied, paid }

class Practice {
  const Practice({
    required this.id,
    required this.name,
    required this.specialty,
  });

  final String id;
  final String name;
  final String specialty;
}

class Booking {
  const Booking({
    required this.id,
    required this.practiceId,
    required this.patientName,
    required this.phoneNumber,
    required this.saId,
    required this.serviceType,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
    this.clinicalFindings,
    this.visitSummary,
  });

  final String id;
  final String practiceId;
  final String patientName;
  final String phoneNumber;
  final String saId;
  final ServiceType serviceType;
  final DateTime appointmentDate;
  final String timeSlot;
  final BookingStatus status;
  final DateTime createdAt;
  final String? clinicalFindings;
  final String? visitSummary;

  Booking copyWith({
    BookingStatus? status,
    String? clinicalFindings,
    String? visitSummary,
  }) => Booking(
    id: id,
    practiceId: practiceId,
    patientName: patientName,
    phoneNumber: phoneNumber,
    saId: saId,
    serviceType: serviceType,
    appointmentDate: appointmentDate,
    timeSlot: timeSlot,
    status: status ?? this.status,
    createdAt: createdAt,
    clinicalFindings: clinicalFindings ?? this.clinicalFindings,
    visitSummary: visitSummary ?? this.visitSummary,
  );
}

class ClaimRecord {
  const ClaimRecord({
    required this.id,
    required this.practiceId,
    required this.bookingId,
    required this.claimAmount,
    required this.createdAt,
    required this.status,
    required this.icd10Code,
    required this.tariffCode,
    required this.validationPassed,
    required this.validationSummary,
    this.statusNote,
  });

  final String id;
  final String practiceId;
  final String bookingId;
  final double claimAmount;
  final DateTime createdAt;
  final ClaimStatus status;
  final String icd10Code;
  final String tariffCode;
  final bool validationPassed;
  final String validationSummary;
  final String? statusNote;

  ClaimRecord copyWith({
    ClaimStatus? status,
    String? statusNote,
    String? icd10Code,
    String? tariffCode,
    bool? validationPassed,
    String? validationSummary,
  }) => ClaimRecord(
    id: id,
    practiceId: practiceId,
    bookingId: bookingId,
    claimAmount: claimAmount,
    createdAt: createdAt,
    status: status ?? this.status,
    icd10Code: icd10Code ?? this.icd10Code,
    tariffCode: tariffCode ?? this.tariffCode,
    validationPassed: validationPassed ?? this.validationPassed,
    validationSummary: validationSummary ?? this.validationSummary,
    statusNote: statusNote ?? this.statusNote,
  );
}

class ClaimAssistEngine {
  static const Map<String, String> icd10Catalog = <String, String>{
    'H52.1': 'Myopia',
    'H52.4': 'Presbyopia',
    'H53.8': 'Other visual disturbances',
    'Z01.0': 'Examination of eyes and vision',
    'Z02.4': 'Examination for driving license',
  };

  static const Map<String, String> tariffCatalog = <String, String>{
    '82001': 'Comprehensive eye examination',
    '82006': 'Visual fields/basic diagnostics',
    '82020': 'Driving license vision certificate',
    '82021': 'Professional driving permit (PDP) certificate',
  };

  static List<String> suggestIcd10({
    required ServiceType serviceType,
    required String clinicalFindings,
  }) {
    final findings = clinicalFindings.toLowerCase();
    final suggested = <String>[];
    if (serviceType == ServiceType.diagnosticAssessment) {
      suggested.add('Z02.4');
    }
    if (serviceType == ServiceType.certificateAssessment) {
      suggested.add('Z02.4');
    }
    if (serviceType == ServiceType.consultation) {
      suggested.add('Z01.0');
    }
    if (findings.contains('myopia') || findings.contains('short-sight')) {
      suggested.add('H52.1');
    }
    if (findings.contains('presbyopia') || findings.contains('near vision')) {
      suggested.add('H52.4');
    }
    if (findings.contains('blur') || findings.contains('disturbance')) {
      suggested.add('H53.8');
    }
    if (suggested.isEmpty) {
      suggested.add('Z01.0');
    }
    return suggested.toSet().toList();
  }

  static List<String> suggestTariff({required ServiceType serviceType}) {
    switch (serviceType) {
      case ServiceType.consultation:
        return const ['82001', '82006'];
      case ServiceType.diagnosticAssessment:
        return const ['82020', '82001'];
      case ServiceType.certificateAssessment:
        return const ['82021', '82020'];
    }
  }

  static List<String> validate({
    required String clinicalFindings,
    required String visitSummary,
    required double claimAmount,
    required String? icd10Code,
    required String? tariffCode,
  }) {
    final issues = <String>[];
    if (clinicalFindings.trim().length < 10) {
      issues.add('Clinical findings are too short.');
    }
    if (visitSummary.trim().length < 10) {
      issues.add('Visit summary is too short.');
    }
    if (claimAmount <= 0) {
      issues.add('Claim amount must be greater than zero.');
    }
    if (icd10Code == null || !icd10Catalog.containsKey(icd10Code)) {
      issues.add('Choose a valid ICD-10 code.');
    }
    if (tariffCode == null || !tariffCatalog.containsKey(tariffCode)) {
      issues.add('Choose a valid tariff code.');
    }
    return issues;
  }

  static String exportText({
    required ClaimRecord claim,
    required Booking? booking,
  }) {
    final patientName = booking?.patientName ?? 'Unknown';
    final patientId = booking?.saId ?? 'Unknown';
    final service = booking == null
        ? 'Unknown'
        : _serviceLabel(booking.serviceType);
    return '''
CLAIM_EXPORT_V1
claim_id=${claim.id}
booking_id=${claim.bookingId}
patient_name=$patientName
patient_id=$patientId
service=$service
icd10=${claim.icd10Code}
icd10_desc=${icd10Catalog[claim.icd10Code] ?? 'Unknown'}
tariff=${claim.tariffCode}
tariff_desc=${tariffCatalog[claim.tariffCode] ?? 'Unknown'}
amount=${claim.claimAmount.toStringAsFixed(2)}
status=${claim.status.name}
validation_passed=${claim.validationPassed}
validation_summary=${claim.validationSummary}
generated_at=${DateTime.now().toIso8601String()}
''';
  }

  static String _serviceLabel(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.consultation:
        return 'Comprehensive Eye Exam';
      case ServiceType.diagnosticAssessment:
        return 'Driving Licence Eye Test';
      case ServiceType.certificateAssessment:
        return 'PDP Eye Certificate';
    }
  }
}

class ManagedFile {
  const ManagedFile({
    required this.id,
    required this.practiceId,
    required this.fileName,
    required this.category,
    required this.sizeBytes,
    required this.uploadedAt,
    required this.patientRef,
    required this.patientName,
    required this.verified,
    required this.source,
    this.bytes,
    this.linkedBookingId,
  });

  final String id;
  final String practiceId;
  final String fileName;
  final String category;
  final int sizeBytes;
  final DateTime uploadedAt;
  final String patientRef;
  final String patientName;
  final bool verified;
  final String source;
  final Uint8List? bytes;
  final String? linkedBookingId;

  ManagedFile copyWith({bool? verified}) => ManagedFile(
    id: id,
    practiceId: practiceId,
    fileName: fileName,
    category: category,
    sizeBytes: sizeBytes,
    uploadedAt: uploadedAt,
    patientRef: patientRef,
    patientName: patientName,
    verified: verified ?? this.verified,
    source: source,
    bytes: bytes,
    linkedBookingId: linkedBookingId,
  );
}

class PendingAuthorization {
  const PendingAuthorization({
    required this.id,
    required this.practiceId,
    required this.patientName,
    required this.medicalAid,
    required this.service,
    required this.requestedAt,
    required this.status,
  });

  final String id;
  final String practiceId;
  final String patientName;
  final String medicalAid;
  final String service;
  final DateTime requestedAt;
  final String status;
}

class BenefitBalance {
  const BenefitBalance({
    required this.id,
    required this.practiceId,
    required this.patientName,
    required this.medicalAid,
    required this.remainingAmount,
    required this.lastUpdatedAt,
  });

  final String id;
  final String practiceId;
  final String patientName;
  final String medicalAid;
  final double remainingAmount;
  final DateTime lastUpdatedAt;
}

class StaffActivity {
  const StaffActivity({
    required this.id,
    required this.practiceId,
    required this.actor,
    required this.action,
    required this.details,
    required this.createdAt,
  });

  final String id;
  final String practiceId;
  final String actor;
  final String action;
  final String details;
  final DateTime createdAt;
}

class EyecareRepository {
  EyecareRepository._() {
    _seedDemoData();
  }
  static final EyecareRepository instance = EyecareRepository._();

  static const List<String> defaultSlots = <String>[
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
  ];

  static const List<Practice> practices = <Practice>[
    Practice(
      id: 'practice-001',
      name: 'Shokane Eyecare',
      specialty: 'Optometry',
    ),
  ];

  final Map<String, List<Booking>> _bookingsByDate = <String, List<Booking>>{};
  final List<ClaimRecord> _claims = <ClaimRecord>[];
  final Map<String, List<ManagedFile>> _filesByPractice =
      <String, List<ManagedFile>>{};
  final List<PendingAuthorization> _pendingAuthorizations =
      <PendingAuthorization>[];
  final List<BenefitBalance> _benefitBalances = <BenefitBalance>[];
  final List<StaffActivity> _staffActivities = <StaffActivity>[];
  DateTime _lastSyncedAt = DateTime.now();
  final StreamController<void> _changes = StreamController<void>.broadcast();
  Stream<void> get changes => _changes.stream;
  DateTime get lastSyncedAt => _lastSyncedAt;

  DateTime normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _emitChange() {
    _lastSyncedAt = DateTime.now();
    _changes.add(null);
  }

  void _logActivity({
    required String practiceId,
    required String actor,
    required String action,
    required String details,
    DateTime? createdAt,
  }) {
    _staffActivities.add(
      StaffActivity(
        id: 'act-${DateTime.now().microsecondsSinceEpoch}',
        practiceId: practiceId,
        actor: actor,
        action: action,
        details: details,
        createdAt: createdAt ?? DateTime.now(),
      ),
    );
  }

  String _key(String practiceId, DateTime date) =>
      '$practiceId|${DateFormat('yyyy-MM-dd').format(normalize(date))}';
  DateTime _slotToDate(DateTime date, String slot) {
    final parts = slot.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = int.tryParse(parts.last) ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  List<Booking> bookingsForDay(String practiceId, DateTime date) {
    final list = _bookingsByDate[_key(practiceId, date)] ?? <Booking>[];
    final copy = List<Booking>.from(list);
    copy.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
    return copy;
  }

  Stream<List<Booking>> watchBookingsForDay(
    String practiceId,
    DateTime date,
  ) async* {
    yield bookingsForDay(practiceId, date);
    yield* _changes.stream.map((_) => bookingsForDay(practiceId, date));
  }

  List<String> availableSlotsForDay(String practiceId, DateTime date) {
    final booked = bookingsForDay(
      practiceId,
      date,
    ).map((b) => b.timeSlot).toSet();
    return defaultSlots.where((slot) => !booked.contains(slot)).toList();
  }

  void createBooking({
    required String practiceId,
    required String patientName,
    required String phoneNumber,
    required String saId,
    required ServiceType serviceType,
    required DateTime appointmentDate,
    required String timeSlot,
  }) {
    final key = _key(practiceId, appointmentDate);
    final list = _bookingsByDate.putIfAbsent(key, () => <Booking>[]);
    final id = '${DateTime.now().millisecondsSinceEpoch}-${list.length + 1}';
    list.add(
      Booking(
        id: id,
        practiceId: practiceId,
        patientName: patientName,
        phoneNumber: phoneNumber,
        saId: saId,
        serviceType: serviceType,
        appointmentDate: _slotToDate(normalize(appointmentDate), timeSlot),
        timeSlot: timeSlot,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    _logActivity(
      practiceId: practiceId,
      actor: 'Front Desk',
      action: 'Diary Booking Created',
      details:
          '$patientName booked for $timeSlot (${_serviceLabel(serviceType)}).',
    );
    _emitChange();
  }

  void updateBookingStatus({
    required String practiceId,
    required String bookingId,
    required DateTime date,
    required BookingStatus status,
  }) {
    final key = _key(practiceId, date);
    final list = _bookingsByDate[key];
    if (list == null) {
      return;
    }
    final index = list.indexWhere((booking) => booking.id == bookingId);
    if (index < 0) {
      return;
    }
    list[index] = list[index].copyWith(status: status);
    _logActivity(
      practiceId: practiceId,
      actor: 'Front Desk',
      action: 'Booking Status Updated',
      details:
          '${list[index].patientName} moved to ${_bookingStatusLabel(status)}.',
    );
    _emitChange();
  }

  void completeVisitAndCreateClaim({
    required Booking booking,
    required String clinicalFindings,
    required String visitSummary,
    required double claimAmount,
    required String icd10Code,
    required String tariffCode,
    required List<String> validationIssues,
  }) {
    updateBookingStatus(
      practiceId: booking.practiceId,
      bookingId: booking.id,
      date: booking.appointmentDate,
      status: BookingStatus.completed,
    );
    final key = _key(booking.practiceId, booking.appointmentDate);
    final list = _bookingsByDate[key];
    if (list != null) {
      final index = list.indexWhere((value) => value.id == booking.id);
      if (index >= 0) {
        list[index] = list[index].copyWith(
          status: BookingStatus.completed,
          clinicalFindings: clinicalFindings,
          visitSummary: visitSummary,
        );
      }
    }
    _claims.add(
      ClaimRecord(
        id: 'claim-${DateTime.now().microsecondsSinceEpoch}',
        practiceId: booking.practiceId,
        bookingId: booking.id,
        claimAmount: claimAmount,
        createdAt: DateTime.now(),
        status: ClaimStatus.draft,
        icd10Code: icd10Code,
        tariffCode: tariffCode,
        validationPassed: validationIssues.isEmpty,
        validationSummary: validationIssues.isEmpty
            ? 'Passed all checks.'
            : validationIssues.join(' | '),
      ),
    );
    _logActivity(
      practiceId: booking.practiceId,
      actor: 'Clinician',
      action: 'Claim Created',
      details:
          '${booking.patientName}: R${claimAmount.toStringAsFixed(2)} with $icd10Code / $tariffCode.',
    );
    _emitChange();
  }

  List<ClaimRecord> claimsForPractice(String practiceId) {
    final claims = _claims
        .where((claim) => claim.practiceId == practiceId)
        .toList(growable: false);
    final sorted = List<ClaimRecord>.from(claims);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Booking? bookingById(String bookingId) {
    for (final dayBookings in _bookingsByDate.values) {
      for (final booking in dayBookings) {
        if (booking.id == bookingId) {
          return booking;
        }
      }
    }
    return null;
  }

  void updateClaimStatus({
    required String claimId,
    required ClaimStatus status,
    String? statusNote,
  }) {
    final index = _claims.indexWhere((claim) => claim.id == claimId);
    if (index < 0) {
      return;
    }
    _claims[index] = _claims[index].copyWith(
      status: status,
      statusNote: statusNote,
    );
    final claim = _claims[index];
    final booking = bookingById(claim.bookingId);
    _logActivity(
      practiceId: claim.practiceId,
      actor: 'Billing',
      action: 'Claim Status Updated',
      details:
          '${booking?.patientName ?? 'Patient'} claim set to ${_claimStatusLabel(status)}.',
    );
    _emitChange();
  }

  void markLatestClaimAsSubmittedForBooking({
    required String practiceId,
    required String bookingId,
  }) {
    final indices = <int>[];
    for (var i = 0; i < _claims.length; i++) {
      if (_claims[i].practiceId == practiceId &&
          _claims[i].bookingId == bookingId) {
        indices.add(i);
      }
    }
    if (indices.isEmpty) {
      return;
    }
    indices.sort(
      (a, b) => _claims[a].createdAt.compareTo(_claims[b].createdAt),
    );
    final latest = indices.last;
    _claims[latest] = _claims[latest].copyWith(
      status: ClaimStatus.submitted,
      statusNote: 'Claim pack generated and ready for submission.',
    );
    final booking = bookingById(bookingId);
    _logActivity(
      practiceId: practiceId,
      actor: 'System',
      action: 'Claim Submitted',
      details:
          'Auto-submitted generated claim pack for ${booking?.patientName ?? 'patient'}.',
    );
    _emitChange();
  }

  List<Booking> allBookingsForPractice(String practiceId) {
    final all = _bookingsByDate.entries
        .where((entry) => entry.key.startsWith('$practiceId|'))
        .expand((entry) => entry.value)
        .toList();
    all.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    return all;
  }

  List<ManagedFile> filesForPractice(String practiceId) {
    final files = _filesByPractice[practiceId] ?? <ManagedFile>[];
    final copy = List<ManagedFile>.from(files);
    copy.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return copy;
  }

  void addManagedFile({
    required String practiceId,
    required String fileName,
    required String category,
    required int sizeBytes,
    required String patientRef,
    required String patientName,
    bool verified = false,
    String source = 'manual_upload',
    Uint8List? bytes,
    String? linkedBookingId,
  }) {
    final files = _filesByPractice.putIfAbsent(
      practiceId,
      () => <ManagedFile>[],
    );
    files.add(
      ManagedFile(
        id: 'file-${DateTime.now().microsecondsSinceEpoch}',
        practiceId: practiceId,
        fileName: fileName,
        category: category,
        sizeBytes: sizeBytes,
        uploadedAt: DateTime.now(),
        patientRef: patientRef,
        patientName: patientName,
        verified: verified,
        source: source,
        bytes: bytes,
        linkedBookingId: linkedBookingId,
      ),
    );
    _logActivity(
      practiceId: practiceId,
      actor: source == 'system_generated' ? 'System' : 'Records Team',
      action: 'File Added to Vault',
      details: '$fileName uploaded for $patientName.',
    );
    _emitChange();
  }

  void addGeneratedClaimPackFile({
    required Booking booking,
    required int sizeBytes,
    required Uint8List bytes,
  }) {
    final filename =
        'claim-pack-${booking.patientName.replaceAll(' ', '_')}-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}.pdf';
    addManagedFile(
      practiceId: booking.practiceId,
      fileName: filename,
      category: 'Claim Docs',
      sizeBytes: sizeBytes,
      patientRef: booking.saId,
      patientName: booking.patientName,
      verified: true,
      source: 'system_generated',
      bytes: bytes,
      linkedBookingId: booking.id,
    );
  }

  void toggleFileVerification({
    required String practiceId,
    required String fileId,
  }) {
    final files = _filesByPractice[practiceId];
    if (files == null) {
      return;
    }
    final index = files.indexWhere((f) => f.id == fileId);
    if (index < 0) {
      return;
    }
    files[index] = files[index].copyWith(verified: !files[index].verified);
    _logActivity(
      practiceId: practiceId,
      actor: 'Records Team',
      action: 'File Verification Toggled',
      details:
          '${files[index].fileName} marked ${files[index].verified ? 'verified' : 'unverified'}.',
    );
    _emitChange();
  }

  List<PendingAuthorization> pendingAuthorizationsForPractice(
    String practiceId,
  ) {
    final list = _pendingAuthorizations
        .where((item) => item.practiceId == practiceId)
        .toList(growable: false);
    final sorted = List<PendingAuthorization>.from(list);
    sorted.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return sorted;
  }

  List<BenefitBalance> benefitBalancesForPractice(String practiceId) {
    final list = _benefitBalances
        .where((item) => item.practiceId == practiceId)
        .toList(growable: false);
    final sorted = List<BenefitBalance>.from(list);
    sorted.sort((a, b) => a.remainingAmount.compareTo(b.remainingAmount));
    return sorted;
  }

  List<StaffActivity> staffActivitiesForPractice(
    String practiceId, {
    int limit = 12,
  }) {
    final list = _staffActivities
        .where((item) => item.practiceId == practiceId)
        .toList(growable: false);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(limit).toList(growable: false);
  }

  List<ClaimRecord> rejectedClaimsForPractice(String practiceId) =>
      claimsForPractice(practiceId)
          .where((claim) => claim.status == ClaimStatus.denied)
          .toList(growable: false);

  List<ClaimRecord> overdueClaimsForPractice(
    String practiceId, {
    int thresholdDays = 14,
  }) {
    final now = DateTime.now();
    return claimsForPractice(practiceId)
        .where((claim) {
          final age = now.difference(claim.createdAt).inDays;
          return claim.status != ClaimStatus.paid && age >= thresholdDays;
        })
        .toList(growable: false);
  }

  List<String> notificationsForPractice(String practiceId) {
    final alerts = <String>[];
    final denied = rejectedClaimsForPractice(practiceId).length;
    final overdue = overdueClaimsForPractice(practiceId).length;
    final pendingAuth = pendingAuthorizationsForPractice(
      practiceId,
    ).where((item) => item.status == 'Pending').length;
    if (denied > 0) {
      alerts.add('$denied rejected claims need attention.');
    }
    if (overdue > 0) {
      alerts.add('$overdue unpaid claims are now overdue.');
    }
    if (pendingAuth > 0) {
      alerts.add('$pendingAuth pre-authorizations are still pending.');
    }
    return alerts;
  }

  Map<String, int> dashboardMetrics(String practiceId, DateTime date) {
    final todayBookings = bookingsForDay(practiceId, date);
    final allBookings = allBookingsForPractice(practiceId);
    final claimCount = _claims.where((c) => c.practiceId == practiceId).length;
    final files = filesForPractice(practiceId);
    final noShows = allBookings
        .where((b) => b.status == BookingStatus.noShow)
        .length;
    final checkedIn = todayBookings
        .where((b) => b.status == BookingStatus.checkedIn)
        .length;
    final deniedClaims = _claims
        .where(
          (c) => c.practiceId == practiceId && c.status == ClaimStatus.denied,
        )
        .length;
    final pendingAuth = pendingAuthorizationsForPractice(
      practiceId,
    ).where((item) => item.status == 'Pending').length;
    return <String, int>{
      'todayBookings': todayBookings.length,
      'checkedIn': checkedIn,
      'claimCount': claimCount,
      'fileCount': files.length,
      'noShows': noShows,
      'deniedClaims': deniedClaims,
      'pendingAuth': pendingAuth,
    };
  }

  void _seedDemoData() {
    if (_bookingsByDate.isNotEmpty || _claims.isNotEmpty) {
      return;
    }
    final practiceId = practices.first.id;
    final now = DateTime.now();
    final today = normalize(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    final bookingA = Booking(
      id: 'seed-booking-001',
      practiceId: practiceId,
      patientName: 'Lerato Mokoena',
      phoneNumber: '071 222 3344',
      saId: '9001015800087',
      serviceType: ServiceType.consultation,
      appointmentDate: _slotToDate(today, '09:00'),
      timeSlot: '09:00',
      status: BookingStatus.checkedIn,
      createdAt: twoDaysAgo,
      clinicalFindings: 'Blurry near vision and headaches by afternoon.',
      visitSummary: 'Needs refraction update and anti-fatigue lens guidance.',
    );
    final bookingB = Booking(
      id: 'seed-booking-002',
      practiceId: practiceId,
      patientName: 'Thabo Nkosi',
      phoneNumber: '072 778 1199',
      saId: '8705125401089',
      serviceType: ServiceType.certificateAssessment,
      appointmentDate: _slotToDate(today, '11:00'),
      timeSlot: '11:00',
      status: BookingStatus.pending,
      createdAt: yesterday,
    );
    final bookingC = Booking(
      id: 'seed-booking-003',
      practiceId: practiceId,
      patientName: 'Nomsa Dlamini',
      phoneNumber: '082 991 4455',
      saId: '9102280606081',
      serviceType: ServiceType.diagnosticAssessment,
      appointmentDate: _slotToDate(yesterday, '14:00'),
      timeSlot: '14:00',
      status: BookingStatus.completed,
      createdAt: twoDaysAgo,
      clinicalFindings:
          'Visual acuity below threshold without corrective lenses.',
      visitSummary:
          'Driver screening complete; referred for full refractive correction.',
    );

    _bookingsByDate[_key(practiceId, today)] = <Booking>[bookingA, bookingB];
    _bookingsByDate[_key(practiceId, yesterday)] = <Booking>[bookingC];

    _claims.addAll(<ClaimRecord>[
      ClaimRecord(
        id: 'seed-claim-001',
        practiceId: practiceId,
        bookingId: bookingC.id,
        claimAmount: 780,
        createdAt: now.subtract(const Duration(days: 18)),
        status: ClaimStatus.denied,
        statusNote: 'Rejected: tariff mismatch vs authorization.',
        icd10Code: 'Z02.4',
        tariffCode: '82020',
        validationPassed: false,
        validationSummary: 'Tariff mismatch and missing supporting attachment.',
      ),
      ClaimRecord(
        id: 'seed-claim-002',
        practiceId: practiceId,
        bookingId: bookingA.id,
        claimAmount: 920,
        createdAt: now.subtract(const Duration(days: 12)),
        status: ClaimStatus.submitted,
        statusNote: 'Submitted to medical aid; awaiting remittance.',
        icd10Code: 'H52.4',
        tariffCode: '82001',
        validationPassed: true,
        validationSummary: 'Passed all checks.',
      ),
      ClaimRecord(
        id: 'seed-claim-003',
        practiceId: practiceId,
        bookingId: bookingA.id,
        claimAmount: 560,
        createdAt: now.subtract(const Duration(days: 4)),
        status: ClaimStatus.paid,
        statusNote: 'Paid and reconciled.',
        icd10Code: 'Z01.0',
        tariffCode: '82006',
        validationPassed: true,
        validationSummary: 'Passed all checks.',
      ),
    ]);

    _pendingAuthorizations.addAll(<PendingAuthorization>[
      PendingAuthorization(
        id: 'auth-001',
        practiceId: practiceId,
        patientName: 'Lerato Mokoena',
        medicalAid: 'Discovery Health',
        service: 'Comprehensive Eye Exam',
        requestedAt: now.subtract(const Duration(hours: 29)),
        status: 'Pending',
      ),
      PendingAuthorization(
        id: 'auth-002',
        practiceId: practiceId,
        patientName: 'Thabo Nkosi',
        medicalAid: 'Bonitas',
        service: 'PDP Certificate',
        requestedAt: now.subtract(const Duration(hours: 8)),
        status: 'Pending',
      ),
      PendingAuthorization(
        id: 'auth-003',
        practiceId: practiceId,
        patientName: 'Nomsa Dlamini',
        medicalAid: 'GEMS',
        service: 'Driver Screening',
        requestedAt: now.subtract(const Duration(days: 2)),
        status: 'Approved',
      ),
    ]);

    _benefitBalances.addAll(<BenefitBalance>[
      BenefitBalance(
        id: 'bal-001',
        practiceId: practiceId,
        patientName: 'Lerato Mokoena',
        medicalAid: 'Discovery Health',
        remainingAmount: 350,
        lastUpdatedAt: now.subtract(const Duration(hours: 4)),
      ),
      BenefitBalance(
        id: 'bal-002',
        practiceId: practiceId,
        patientName: 'Thabo Nkosi',
        medicalAid: 'Bonitas',
        remainingAmount: 0,
        lastUpdatedAt: now.subtract(const Duration(days: 1)),
      ),
      BenefitBalance(
        id: 'bal-003',
        practiceId: practiceId,
        patientName: 'Nomsa Dlamini',
        medicalAid: 'GEMS',
        remainingAmount: 540,
        lastUpdatedAt: now.subtract(const Duration(hours: 2)),
      ),
    ]);

    _staffActivities.addAll(<StaffActivity>[
      StaffActivity(
        id: 'seed-act-001',
        practiceId: practiceId,
        actor: 'Front Desk',
        action: 'Check-In',
        details: 'Lerato Mokoena checked in.',
        createdAt: now.subtract(const Duration(minutes: 22)),
      ),
      StaffActivity(
        id: 'seed-act-002',
        practiceId: practiceId,
        actor: 'Clinician',
        action: 'Clinical Notes',
        details: 'Updated findings for Nomsa Dlamini.',
        createdAt: now.subtract(const Duration(minutes: 48)),
      ),
      StaffActivity(
        id: 'seed-act-003',
        practiceId: practiceId,
        actor: 'Billing',
        action: 'Claim Review',
        details: 'Denied claim queued for correction.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      StaffActivity(
        id: 'seed-act-004',
        practiceId: practiceId,
        actor: 'Records Team',
        action: 'File Verification',
        details: 'Verified signed consent and ID copy.',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  String _bookingStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.checkedIn:
        return 'Checked-In';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.noShow:
        return 'No-Show';
    }
  }

  String _claimStatusLabel(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return 'Draft';
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.denied:
        return 'Denied';
      case ClaimStatus.paid:
        return 'Paid';
    }
  }

  String _serviceLabel(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.consultation:
        return 'Comprehensive Eye Exam';
      case ServiceType.diagnosticAssessment:
        return 'Driving Licence Eye Test';
      case ServiceType.certificateAssessment:
        return 'PDP Eye Certificate';
    }
  }
}

class DocumentService {
  Future<Uint8List> buildClaimPack({
    required Practice practice,
    required Booking booking,
    required String clinicalFindings,
    required String visitSummary,
    required double claimAmount,
  }) async {
    final doc = pw.Document();
    final money = NumberFormat.currency(locale: 'en_ZA', symbol: 'R');
    final dateFormat = DateFormat('dd MMM yyyy');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            practice.name.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Pilot Claim Pack / Visit Document'),
          pw.SizedBox(height: 20),
          _section('Patient Details'),
          _pair('Patient Name', booking.patientName),
          _pair('Phone Number', booking.phoneNumber),
          _pair('SA ID', booking.saId),
          _pair('Service', _serviceLabel(booking.serviceType)),
          _pair('Date', dateFormat.format(booking.appointmentDate)),
          _pair('Time Slot', booking.timeSlot),
          pw.SizedBox(height: 16),
          _section('Clinical Findings'),
          _textBox(clinicalFindings),
          pw.SizedBox(height: 16),
          _section('Visit Summary'),
          _textBox(visitSummary),
          pw.SizedBox(height: 16),
          _section('Billing'),
          _pair('Claim Amount', money.format(claimAmount)),
          _pair(
            'Generated',
            DateFormat('dd MMM yyyy HH:mm').format(DateTime.now()),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Generated for pilot demonstration purposes.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );
    return doc.save();
  }

  Future<Uint8List> printClaimPack({
    required Practice practice,
    required Booking booking,
    required String clinicalFindings,
    required String visitSummary,
    required double claimAmount,
  }) async {
    final bytes = await buildClaimPack(
      practice: practice,
      booking: booking,
      clinicalFindings: clinicalFindings,
      visitSummary: visitSummary,
      claimAmount: claimAmount,
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);
    return bytes;
  }

  pw.Widget _section(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(
      title,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
    ),
  );

  pw.Widget _pair(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColors.blueGrey600,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(child: pw.Text(value)),
      ],
    ),
  );

  pw.Widget _textBox(String text) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.blueGrey100),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Text(text.trim().isEmpty ? 'N/A' : text),
  );

  String _serviceLabel(ServiceType service) {
    switch (service) {
      case ServiceType.consultation:
        return 'Comprehensive Eye Exam';
      case ServiceType.diagnosticAssessment:
        return 'Driving Licence Eye Test';
      case ServiceType.certificateAssessment:
        return 'PDP Eye Certificate';
    }
  }
}

enum AppModule {
  frontDesk,
  clinicalClaims,
  recordsVault,
  patients,
  billing,
  inventory,
  reports,
}

class EyecarePilotScreen extends StatefulWidget {
  const EyecarePilotScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<EyecarePilotScreen> createState() => _EyecarePilotScreenState();
}

class _EyecarePilotScreenState extends State<EyecarePilotScreen> {
  final repository = EyecareRepository.instance;
  final documents = DocumentService();
  AppModule selectedModule = AppModule.frontDesk;
  Practice selectedPractice = EyecareRepository.practices.first;
  bool forceCompactRail = false;

  int _mobileNavIndexFor(AppModule module) {
    switch (module) {
      case AppModule.frontDesk:
        return 0;
      case AppModule.clinicalClaims:
        return 1;
      case AppModule.recordsVault:
        return 2;
      case AppModule.patients:
      case AppModule.billing:
      case AppModule.inventory:
      case AppModule.reports:
        return 3;
    }
  }

  void _onMobileNavTap(int index) {
    switch (index) {
      case 0:
        setState(() => selectedModule = AppModule.frontDesk);
        return;
      case 1:
        setState(() => selectedModule = AppModule.clinicalClaims);
        return;
      case 2:
        setState(() => selectedModule = AppModule.recordsVault);
        return;
      case 3:
        _openMoreModulesSheet();
        return;
    }
  }

  Future<void> _openMoreModulesSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppPalette.border),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _mobileModuleTile(
                AppModule.patients,
                Icons.people_alt_outlined,
                'Patients',
              ),
              _mobileModuleTile(
                AppModule.billing,
                Icons.receipt_long_outlined,
                'Billing',
              ),
              _mobileModuleTile(
                AppModule.inventory,
                Icons.inventory_2_outlined,
                'Stock',
              ),
              _mobileModuleTile(
                AppModule.reports,
                Icons.analytics_outlined,
                'Reports',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileModuleTile(AppModule module, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppPalette.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        setState(() => selectedModule = module);
      },
    );
  }

  Future<void> _openNotificationsSheet() async {
    final alerts = repository.notificationsForPractice(selectedPractice.id);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppPalette.border),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: alerts.isEmpty
                ? const [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF1F9C64),
                      ),
                      title: Text(
                        'All operational queues are within normal range.',
                      ),
                    ),
                  ]
                : alerts
                      .map(
                        (alert) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.notifications_active_outlined,
                            color: AppPalette.primary,
                          ),
                          title: Text(alert),
                        ),
                      )
                      .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width > 980;
    final mobile = width < 760;
    final compactRail = !desktop || forceCompactRail;

    return Scaffold(
      bottomNavigationBar: mobile
          ? NavigationBar(
              selectedIndex: _mobileNavIndexFor(selectedModule),
              onDestinationSelected: _onMobileNavTap,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.today_outlined),
                  label: 'Front',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medical_services_outlined),
                  label: 'Clinical',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_copy_outlined),
                  label: 'Vault',
                ),
                NavigationDestination(
                  icon: Icon(Icons.apps_outlined),
                  label: 'More',
                ),
              ],
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFFFEBEE), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _Header(
                selectedPractice: selectedPractice,
                metrics: repository.dashboardMetrics(
                  selectedPractice.id,
                  DateTime.now(),
                ),
                isDarkMode: widget.isDarkMode,
                onToggleTheme: widget.onToggleTheme,
                onOpenNotifications: _openNotificationsSheet,
                alertCount: repository
                    .notificationsForPractice(selectedPractice.id)
                    .length,
                lastSyncedAt: repository.lastSyncedAt,
                onToggleRailMode: () {
                  if (desktop) {
                    setState(() => forceCompactRail = !forceCompactRail);
                  }
                },
                compactRail: compactRail,
                isMobile: mobile,
              ),
              Expanded(
                child: Row(
                  children: [
                    if (!mobile)
                      _ModuleRail(
                        selectedModule: selectedModule,
                        onSelect: (module) =>
                            setState(() => selectedModule = module),
                        compact: compactRail,
                      ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0.03, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        child: _buildModule(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModule() {
    switch (selectedModule) {
      case AppModule.frontDesk:
        return BookingPanel(
          repository: repository,
          selectedPractice: selectedPractice,
          onGoClinicalClaims: () =>
              setState(() => selectedModule = AppModule.clinicalClaims),
          onGoRecordsVault: () =>
              setState(() => selectedModule = AppModule.recordsVault),
        );
      case AppModule.clinicalClaims:
        return StaffPanel(
          repository: repository,
          documents: documents,
          selectedPractice: selectedPractice,
        );
      case AppModule.recordsVault:
        return RecordsPanel(
          repository: repository,
          selectedPractice: selectedPractice,
        );
      case AppModule.patients:
        return PatientsHubPanel(
          repository: repository,
          selectedPractice: selectedPractice,
        );
      case AppModule.billing:
        return BillingHubPanel(
          repository: repository,
          selectedPractice: selectedPractice,
        );
      case AppModule.inventory:
        return InventoryHubPanel(selectedPractice: selectedPractice);
      case AppModule.reports:
        return ReportsHubPanel(
          repository: repository,
          selectedPractice: selectedPractice,
        );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.selectedPractice,
    required this.metrics,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onOpenNotifications,
    required this.alertCount,
    required this.lastSyncedAt,
    required this.onToggleRailMode,
    required this.compactRail,
    required this.isMobile,
  });

  final Practice selectedPractice;
  final Map<String, int> metrics;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenNotifications;
  final int alertCount;
  final DateTime lastSyncedAt;
  final VoidCallback onToggleRailMode;
  final bool compactRail;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, isMobile ? 10 : 14, 12, 10),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 14 : 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppPalette.primary,
              AppPalette.secondary,
              AppPalette.accent,
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A1E3A5F),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Shokane Eyecare Pilot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x4CFFFFFF)),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!isMobile)
                  IconButton(
                    tooltip: compactRail
                        ? 'Expand sidebar'
                        : 'Collapse sidebar',
                    onPressed: onToggleRailMode,
                    icon: Icon(
                      compactRail
                          ? Icons.view_week_outlined
                          : Icons.view_day_outlined,
                      color: Colors.white,
                    ),
                  ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      tooltip: 'Operational alerts',
                      onPressed: onOpenNotifications,
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: Colors.white,
                      ),
                    ),
                    if (alertCount > 0)
                      Positioned(
                        right: 6,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$alertCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppPalette.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  tooltip: isDarkMode
                      ? 'Switch to light mode'
                      : 'Switch to dark mode',
                  onPressed: onToggleTheme,
                  icon: Icon(
                    isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Private practice command center for ${selectedPractice.name}.',
              style: const TextStyle(
                color: Color(0xFFE8F4FF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last synced ${DateFormat('HH:mm:ss').format(lastSyncedAt)} • '
              '${metrics['deniedClaims'] ?? 0} denied claims • '
              '${metrics['pendingAuth'] ?? 0} pending auth',
              style: const TextStyle(
                color: Color(0xFFE8F4FF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _kpi('Today', '${metrics['todayBookings']}'),
                _kpi('Checked-In', '${metrics['checkedIn']}'),
                _kpi('Claims', '${metrics['claimCount']}'),
                _kpi('Files', '${metrics['fileCount']}'),
                _kpi('No-Shows', '${metrics['noShows']}'),
              ],
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickPill(label: 'Fast Claims'),
                _QuickPill(label: 'AR Focus'),
                _QuickPill(label: 'Low No-Shows'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x2CFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4CFFFFFF)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _QuickPill extends StatelessWidget {
  const _QuickPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFEAF4FF),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ModuleRail extends StatelessWidget {
  const _ModuleRail({
    required this.selectedModule,
    required this.onSelect,
    required this.compact,
  });

  final AppModule selectedModule;
  final ValueChanged<AppModule> onSelect;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const modules = <(AppModule, IconData, String)>[
      (AppModule.frontDesk, Icons.today_outlined, 'Front Desk'),
      (
        AppModule.clinicalClaims,
        Icons.medical_services_outlined,
        'Clinical & Claims',
      ),
      (AppModule.recordsVault, Icons.folder_copy_outlined, 'Records Vault'),
      (AppModule.patients, Icons.people_alt_outlined, 'Patients'),
      (AppModule.billing, Icons.receipt_long_outlined, 'Billing'),
      (AppModule.inventory, Icons.inventory_2_outlined, 'Stock'),
      (AppModule.reports, Icons.analytics_outlined, 'Reports'),
    ];

    if (compact) {
      return Container(
        width: 90,
        margin: const EdgeInsets.fromLTRB(12, 0, 8, 12),
        decoration: BoxDecoration(
          color: AppPalette.sidebar,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.sidebarBorder),
        ),
        child: ListView(
          children: modules
              .map(
                (m) => IconButton(
                  tooltip: m.$3,
                  onPressed: () => onSelect(m.$1),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedModule == m.$1
                          ? AppPalette.sidebarSelected
                          : const Color(0xFF455A64),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      m.$2,
                      color: selectedModule == m.$1
                          ? AppPalette.sidebarIconActive
                          : AppPalette.sidebarIcon,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    return Container(
      width: 250,
      margin: const EdgeInsets.fromLTRB(12, 0, 8, 12),
      decoration: BoxDecoration(
        color: AppPalette.sidebar,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.sidebarBorder),
      ),
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 6, 8, 10),
            child: Text(
              'Practice Modules',
              style: TextStyle(
                color: AppPalette.sidebarIcon,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          ...modules.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                selected: selectedModule == m.$1,
                selectedTileColor: const Color(0x22FF8A65),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedModule == m.$1
                        ? AppPalette.sidebarSelected
                        : const Color(0xFF455A64),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    m.$2,
                    color: selectedModule == m.$1
                        ? AppPalette.sidebarIconActive
                        : AppPalette.sidebarIcon,
                  ),
                ),
                title: Text(
                  m.$3,
                  style: TextStyle(
                    color: selectedModule == m.$1
                        ? AppPalette.secondary
                        : const Color(0xFFFFFFFF),
                    fontWeight: selectedModule == m.$1
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                onTap: () => onSelect(m.$1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingPanel extends StatefulWidget {
  const BookingPanel({
    super.key,
    required this.repository,
    required this.selectedPractice,
    required this.onGoClinicalClaims,
    required this.onGoRecordsVault,
  });
  final EyecareRepository repository;
  final Practice selectedPractice;
  final VoidCallback onGoClinicalClaims;
  final VoidCallback onGoRecordsVault;

  @override
  State<BookingPanel> createState() => _BookingPanelState();
}

class _BookingPanelState extends State<BookingPanel> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final idController = TextEditingController();

  ServiceType serviceType = ServiceType.consultation;
  DateTime date = DateTime.now();
  String? selectedSlot;
  List<String> availableSlots = <String>[];

  @override
  void initState() {
    super.initState();
    _refreshSlots();
  }

  @override
  void didUpdateWidget(covariant BookingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPractice.id != widget.selectedPractice.id) {
      _refreshSlots();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    idController.dispose();
    super.dispose();
  }

  void _refreshSlots() {
    final slots = widget.repository.availableSlotsForDay(
      widget.selectedPractice.id,
      date,
    );
    setState(() {
      availableSlots = slots;
      if (selectedSlot == null || !slots.contains(selectedSlot)) {
        selectedSlot = slots.isNotEmpty ? slots.first : null;
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked == null) {
      return;
    }
    date = picked;
    _refreshSlots();
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    if (selectedSlot == null) {
      _show('No slot available on this date.');
      return;
    }
    widget.repository.createBooking(
      practiceId: widget.selectedPractice.id,
      patientName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      saId: idController.text.trim(),
      serviceType: serviceType,
      appointmentDate: date,
      timeSlot: selectedSlot!,
    );
    final workflowNote =
        'Client ${nameController.text.trim()} saved to diary for ${DateFormat('dd MMM, HH:mm').format(DateTime(date.year, date.month, date.day, int.parse(selectedSlot!.split(':')[0]), int.parse(selectedSlot!.split(':')[1])))}.';
    _show('Diary entry saved for ${widget.selectedPractice.name}.');
    nameController.clear();
    phoneController.clear();
    idController.clear();
    _refreshSlots();
    _showNextWorkflowSheet(workflowNote);
  }

  void _show(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _showNextWorkflowSheet(String workflowNote) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppPalette.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.alt_route_rounded, color: AppPalette.primary),
                  SizedBox(width: 8),
                  Text(
                    'Next Workflow Step',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                workflowNote,
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPalette.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1) Check-In on arrival',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2) Complete exam + claim quality check',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3) Generate claim pack -> auto-saved to vault',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onGoClinicalClaims();
                    },
                    icon: const Icon(Icons.medical_services_outlined),
                    label: const Text('Open Clinical & Claims'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.primary,
                      side: const BorderSide(color: AppPalette.border),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onGoRecordsVault();
                    },
                    icon: const Icon(Icons.folder_copy_outlined),
                    label: const Text('Open Records Vault'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('booking'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Front Desk Intake & Diary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ServiceType.values.map((value) {
                  return ChoiceChip(
                    selected: serviceType == value,
                    label: Text(_serviceLabel(value)),
                    selectedColor: const Color(0xFFCCE5FF),
                    onSelected: (_) => setState(() => serviceType = value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppPalette.atlanticSand),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range_outlined,
                        color: AppPalette.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('EEE, dd MMM yyyy').format(date),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Assign Diary Slot',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (availableSlots.isEmpty)
                const Text('No diary slots available for selected date.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSlots.map((slot) {
                    return ChoiceChip(
                      selected: selectedSlot == slot,
                      label: Text(slot),
                      selectedColor: const Color(0xFFD4F3E1),
                      onSelected: (_) => setState(() => selectedSlot = slot),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Client Intake Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 14),
                _field(
                  nameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) =>
                      value.trim().length < 3 ? 'Enter full name' : null,
                ),
                const SizedBox(height: 10),
                _field(
                  phoneController,
                  hint: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value.trim().length < 10
                      ? 'Enter valid phone number'
                      : null,
                ),
                const SizedBox(height: 10),
                _field(
                  idController,
                  hint: 'South African ID Number',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) => value.trim().length < 8
                      ? 'Enter ID or passport number'
                      : null,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Save To Diary'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller, {
    required String hint,
    required IconData icon,
    required String? Function(String value) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => validator((value ?? '').trim()),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.atlanticSand),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.atlanticSand),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120C3059),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  String _serviceLabel(ServiceType value) {
    switch (value) {
      case ServiceType.consultation:
        return 'Comprehensive Eye Exam';
      case ServiceType.diagnosticAssessment:
        return 'Driving Licence Eye Test';
      case ServiceType.certificateAssessment:
        return 'PDP Eye Certificate';
    }
  }
}

class StaffPanel extends StatefulWidget {
  const StaffPanel({
    super.key,
    required this.repository,
    required this.documents,
    required this.selectedPractice,
  });

  final EyecareRepository repository;
  final DocumentService documents;
  final Practice selectedPractice;

  @override
  State<StaffPanel> createState() => _StaffPanelState();
}

class _StaffPanelState extends State<StaffPanel> {
  DateTime date = DateTime.now();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 14)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked == null) {
      return;
    }
    setState(() => date = picked);
  }

  Future<void> _completeBooking(Booking booking) async {
    final result = await _openDialog(booking);
    if (result == null) {
      return;
    }
    widget.repository.completeVisitAndCreateClaim(
      booking: booking,
      clinicalFindings: result.clinicalFindings,
      visitSummary: result.visitSummary,
      claimAmount: result.claimAmount,
      icd10Code: result.icd10Code,
      tariffCode: result.tariffCode,
      validationIssues: result.validationIssues,
    );
    final pdfBytes = await widget.documents.printClaimPack(
      practice: widget.selectedPractice,
      booking: booking,
      clinicalFindings: result.clinicalFindings,
      visitSummary: result.visitSummary,
      claimAmount: result.claimAmount,
    );
    widget.repository.addGeneratedClaimPackFile(
      booking: booking,
      sizeBytes: pdfBytes.length,
      bytes: pdfBytes,
    );
    widget.repository.markLatestClaimAsSubmittedForBooking(
      practiceId: booking.practiceId,
      bookingId: booking.id,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Visit completed. Claim pack generated and saved to vault.',
        ),
      ),
    );
  }

  Future<_ClaimDialogResult?> _openDialog(Booking booking) {
    final findings = TextEditingController(
      text: booking.clinicalFindings ?? '',
    );
    final summary = TextEditingController(text: booking.visitSummary ?? '');
    final amount = TextEditingController(
      text: _suggestedAmount(booking.serviceType).toStringAsFixed(2),
    );
    String? selectedIcd10;
    String? selectedTariff;
    List<String> validationIssues = <String>[];

    return showDialog<_ClaimDialogResult>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final icdSuggestions = ClaimAssistEngine.suggestIcd10(
            serviceType: booking.serviceType,
            clinicalFindings: findings.text,
          );
          final tariffSuggestions = ClaimAssistEngine.suggestTariff(
            serviceType: booking.serviceType,
          );
          selectedIcd10 ??= icdSuggestions.first;
          selectedTariff ??= tariffSuggestions.first;
          return AlertDialog(
            title: const Text('Complete Visit & Claim Assist'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: findings,
                    maxLines: 3,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Clinical Findings',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: summary,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Visit Summary',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Claim Amount (R)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedIcd10,
                    items: icdSuggestions
                        .map(
                          (code) => DropdownMenuItem<String>(
                            value: code,
                            child: Text(
                              '$code — ${ClaimAssistEngine.icd10Catalog[code]}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedIcd10 = value),
                    decoration: const InputDecoration(
                      labelText: 'ICD-10 Suggestion',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedTariff,
                    items: tariffSuggestions
                        .map(
                          (code) => DropdownMenuItem<String>(
                            value: code,
                            child: Text(
                              '$code — ${ClaimAssistEngine.tariffCatalog[code]}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedTariff = value),
                    decoration: const InputDecoration(
                      labelText: 'Tariff Helper',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Validation checks cover documentation quality, coding completeness, and amount.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6A768A)),
                  ),
                  if (validationIssues.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...validationIssues.map(
                      (issue) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $issue',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFAD2C2C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final claimAmount = double.tryParse(amount.text.trim()) ?? 0;
                  final issues = ClaimAssistEngine.validate(
                    clinicalFindings: findings.text,
                    visitSummary: summary.text,
                    claimAmount: claimAmount,
                    icd10Code: selectedIcd10,
                    tariffCode: selectedTariff,
                  );
                  if (issues.isNotEmpty) {
                    setDialogState(() => validationIssues = issues);
                    return;
                  }
                  Navigator.pop(
                    context,
                    _ClaimDialogResult(
                      clinicalFindings: findings.text.trim(),
                      visitSummary: summary.text.trim(),
                      claimAmount: claimAmount,
                      icd10Code: selectedIcd10!,
                      tariffCode: selectedTariff!,
                      validationIssues: issues,
                    ),
                  );
                },
                child: const Text('Generate'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = widget.repository.dashboardMetrics(
      widget.selectedPractice.id,
      date,
    );
    return Column(
      key: const ValueKey('staff'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppPalette.atlanticSand),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_note_outlined,
                  color: AppPalette.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(date),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  widget.selectedPractice.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppPalette.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Change Day'),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metricChip('Today', '${metrics['todayBookings']}', Icons.today),
              _metricChip(
                'Checked-In',
                '${metrics['checkedIn']}',
                Icons.how_to_reg,
              ),
              _metricChip(
                'Claims',
                '${metrics['claimCount']}',
                Icons.receipt_long,
              ),
              _metricChip(
                'Files',
                '${metrics['fileCount']}',
                Icons.folder_copy,
              ),
              _metricChip(
                'No-Shows',
                '${metrics['noShows']}',
                Icons.person_off,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPalette.atlanticSand),
            ),
            child: const Text(
              'Opportunity Radar: reduce no-shows with staged reminders, prevent claim denials using quality gates, and speed retrieval with indexed patient files.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Booking>>(
            stream: widget.repository.watchBookingsForDay(
              widget.selectedPractice.id,
              date,
            ),
            initialData: widget.repository.bookingsForDay(
              widget.selectedPractice.id,
              date,
            ),
            builder: (context, snapshot) {
              final bookings = snapshot.data ?? <Booking>[];
              if (bookings.isEmpty) {
                return Center(
                  child: Text(
                    'No bookings for ${widget.selectedPractice.name} on this date yet.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppPalette.atlanticSand),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x110C3059),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppPalette.primary,
                              child: Text(
                                booking.patientName
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.patientName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${booking.timeSlot} - ${_serviceLabel(booking.serviceType)}',
                                  ),
                                ],
                              ),
                            ),
                            _statusChip(booking.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Phone: ${booking.phoneNumber}  |  ID: ${booking.saId}',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: booking.status == BookingStatus.pending
                                  ? () => widget.repository.updateBookingStatus(
                                      practiceId: widget.selectedPractice.id,
                                      bookingId: booking.id,
                                      date: booking.appointmentDate,
                                      status: BookingStatus.checkedIn,
                                    )
                                  : null,
                              icon: const Icon(Icons.login),
                              label: const Text('Check-In'),
                            ),
                            OutlinedButton.icon(
                              onPressed:
                                  booking.status == BookingStatus.completed
                                  ? null
                                  : () => widget.repository.updateBookingStatus(
                                      practiceId: widget.selectedPractice.id,
                                      bookingId: booking.id,
                                      date: booking.appointmentDate,
                                      status: BookingStatus.noShow,
                                    ),
                              icon: const Icon(Icons.person_off_outlined),
                              label: const Text('No-Show'),
                            ),
                            FilledButton.icon(
                              onPressed:
                                  booking.status == BookingStatus.completed
                                  ? null
                                  : () => _completeBooking(booking),
                              icon: const Icon(Icons.description_outlined),
                              label: const Text('Complete + Claim Pack'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _metricChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.atlanticSand),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppPalette.primary),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BookingStatus status) {
    late final Color color;
    late final String label;
    switch (status) {
      case BookingStatus.pending:
        color = const Color(0xFFE9A300);
        label = 'Pending';
        break;
      case BookingStatus.checkedIn:
        color = const Color(0xFF0D84C9);
        label = 'Checked In';
        break;
      case BookingStatus.completed:
        color = const Color(0xFF1A9D5C);
        label = 'Completed';
        break;
      case BookingStatus.noShow:
        color = const Color(0xFFCC3A3A);
        label = 'No-Show';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  double _suggestedAmount(ServiceType type) {
    switch (type) {
      case ServiceType.consultation:
        return 450;
      case ServiceType.diagnosticAssessment:
        return 550;
      case ServiceType.certificateAssessment:
        return 350;
    }
  }

  String _serviceLabel(ServiceType value) {
    switch (value) {
      case ServiceType.consultation:
        return 'Comprehensive Eye Exam';
      case ServiceType.diagnosticAssessment:
        return 'Driving Licence Eye Test';
      case ServiceType.certificateAssessment:
        return 'PDP Eye Certificate';
    }
  }
}

class RecordsPanel extends StatefulWidget {
  const RecordsPanel({
    super.key,
    required this.repository,
    required this.selectedPractice,
  });

  final EyecareRepository repository;
  final Practice selectedPractice;

  @override
  State<RecordsPanel> createState() => _RecordsPanelState();
}

class _RecordsPanelState extends State<RecordsPanel> {
  String selectedCategory = 'Claim Docs';
  final patientRefController = TextEditingController();
  final patientNameController = TextEditingController();
  final searchController = TextEditingController();

  @override
  void dispose() {
    patientRefController.dispose();
    patientNameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAndAddFile() async {
    final ref = patientRefController.text.trim();
    final patientName = patientNameController.text.trim();
    if (ref.isEmpty || patientName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter patient name and ID/reference first.'),
        ),
      );
      return;
    }

    final result = await FilePicker.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.first;
    final displayName = '${patientName.replaceAll(' ', '_')}-${file.name}';
    widget.repository.addManagedFile(
      practiceId: widget.selectedPractice.id,
      fileName: displayName,
      category: selectedCategory,
      sizeBytes: file.size,
      patientRef: ref,
      patientName: patientName,
      bytes: file.bytes,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File saved to vault: ${file.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: widget.repository.changes,
      builder: (context, snapshot) {
        final allFiles = widget.repository.filesForPractice(
          widget.selectedPractice.id,
        );
        final search = searchController.text.trim().toLowerCase();
        final files = allFiles.where((file) {
          if (search.isEmpty) return true;
          return file.fileName.toLowerCase().contains(search) ||
              file.patientRef.toLowerCase().contains(search) ||
              file.category.toLowerCase().contains(search);
        }).toList();

        return ListView(
          key: const ValueKey('records'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: LinearProgressIndicator(minHeight: 3),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppPalette.atlanticSand),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient File Vault',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Practice records management for claims, scans, consents, and legal audit trails.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: patientNameController,
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: patientRefController,
                    decoration: const InputDecoration(
                      labelText: 'Patient ID / File Reference',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: const [
                      DropdownMenuItem(
                        value: 'Claim Docs',
                        child: Text('Claim Docs'),
                      ),
                      DropdownMenuItem(
                        value: 'Clinical Scan',
                        child: Text('Clinical Scan'),
                      ),
                      DropdownMenuItem(
                        value: 'ID / Consent',
                        child: Text('ID / Consent'),
                      ),
                      DropdownMenuItem(
                        value: 'Prescription',
                        child: Text('Prescription'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCategory = value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _pickAndAddFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload To Vault'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search by file, patient, or category...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (files.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No files yet in the vault.'),
                ),
              )
            else
              ...files.map(
                (file) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppPalette.atlanticSand),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: AppPalette.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${file.patientName} | ${file.category} | ${file.patientRef} | ${(file.sizeBytes / 1024).toStringAsFixed(1)} KB',
                              style: const TextStyle(
                                color: Color(0xFF5E6A7F),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              file.source == 'system_generated'
                                  ? 'Source: System Generated'
                                  : 'Source: Manual Upload',
                              style: const TextStyle(
                                color: Color(0xFF5E6A7F),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            widget.repository.toggleFileVerification(
                              practiceId: widget.selectedPractice.id,
                              fileId: file.id,
                            ),
                        child: Text(
                          file.verified ? 'Verified' : 'Mark Verified',
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: file.bytes == null
                            ? null
                            : () async {
                                final isPdf = file.fileName
                                    .toLowerCase()
                                    .endsWith('.pdf');
                                if (isPdf) {
                                  await Printing.layoutPdf(
                                    onLayout: (_) async => file.bytes!,
                                  );
                                } else {
                                  await Printing.sharePdf(
                                    bytes: file.bytes!,
                                    filename: file.fileName,
                                  );
                                }
                              },
                        child: const Text('View'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PatientsHubPanel extends StatelessWidget {
  const PatientsHubPanel({
    super.key,
    required this.repository,
    required this.selectedPractice,
  });

  final EyecareRepository repository;
  final Practice selectedPractice;

  Future<void> _openPatientWorkspace(
    BuildContext context,
    Booking booking,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.border),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.patientName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${booking.saId} • ${booking.phoneNumber}',
                style: const TextStyle(color: AppPalette.textMuted),
              ),
              const SizedBox(height: 10),
              Text(
                'Visit: ${booking.timeSlot} • ${_statusLabel(booking.status)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.medical_services_outlined),
                    label: const Text('Clinical'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Claims'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.folder_outlined),
                    label: const Text('Records'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = repository
        .bookingsForDay(selectedPractice.id, DateTime.now())
        .toList(growable: false);
    final history = repository
        .allBookingsForPractice(selectedPractice.id)
        .take(8)
        .toList();
    final balances = repository.benefitBalancesForPractice(selectedPractice.id);
    final authorizations = repository.pendingAuthorizationsForPractice(
      selectedPractice.id,
    );

    return ListView(
      key: const ValueKey('patientsHub'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        _sectionCard(
          title: 'Patient Workspace',
          subtitle:
              'Fast access to today\'s arrivals, clinical status, and contact details.',
          child: bookings.isEmpty
              ? const Text('No patient visits in today\'s diary.')
              : Column(
                  children: bookings
                      .map(
                        (booking) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => _openPatientWorkspace(context, booking),
                          leading: CircleAvatar(
                            child: Text(
                              booking.patientName.substring(0, 1).toUpperCase(),
                            ),
                          ),
                          title: Text(booking.patientName),
                          subtitle: Text(
                            '${booking.timeSlot} • ${booking.phoneNumber} • ${_statusLabel(booking.status)}',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Recent Patient Timeline',
          subtitle:
              'Quick chronological feed for follow-ups and recall planning.',
          child: history.isEmpty
              ? const Text('No historical interactions yet.')
              : Column(
                  children: history
                      .map(
                        (booking) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.history,
                            color: Color(0xFF4A6A90),
                          ),
                          title: Text(booking.patientName),
                          subtitle: Text(
                            '${DateFormat('dd MMM HH:mm').format(booking.appointmentDate)} • ${_statusLabel(booking.status)}',
                          ),
                          trailing: Text(
                            booking.saId,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF60738F),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Medical Aid Benefit Balances',
          subtitle:
              'Remaining optical benefits to prevent denied or short-paid claims.',
          child: balances.isEmpty
              ? const Text('No balance records yet.')
              : Column(
                  children: balances
                      .map(
                        (balance) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppPalette.primary,
                          ),
                          title: Text(
                            '${balance.patientName} • ${balance.medicalAid}',
                          ),
                          subtitle: Text(
                            'Updated ${DateFormat('dd MMM HH:mm').format(balance.lastUpdatedAt)}',
                          ),
                          trailing: Text(
                            'R${balance.remainingAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: balance.remainingAmount <= 0
                                  ? const Color(0xFFB3261E)
                                  : const Color(0xFF1F9C64),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Pending Authorizations',
          subtitle:
              'Live pre-authorization queue for high-trust claim readiness.',
          child: authorizations.isEmpty
              ? const Text('No authorization requests.')
              : Column(
                  children: authorizations
                      .map(
                        (auth) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.pending_actions_outlined,
                            color: AppPalette.primary,
                          ),
                          title: Text(
                            '${auth.patientName} • ${auth.medicalAid}',
                          ),
                          subtitle: Text(
                            '${auth.service} • Requested ${DateFormat('dd MMM HH:mm').format(auth.requestedAt)}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: auth.status == 'Approved'
                                  ? const Color(0x261F9C64)
                                  : const Color(0x26FF8A65),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              auth.status,
                              style: TextStyle(
                                color: auth.status == 'Approved'
                                    ? const Color(0xFF1F9C64)
                                    : AppPalette.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.checkedIn:
        return 'Checked-In';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.noShow:
        return 'No-Show';
    }
  }
}

class BillingHubPanel extends StatefulWidget {
  const BillingHubPanel({
    super.key,
    required this.repository,
    required this.selectedPractice,
  });

  final EyecareRepository repository;
  final Practice selectedPractice;

  @override
  State<BillingHubPanel> createState() => _BillingHubPanelState();
}

class _BillingHubPanelState extends State<BillingHubPanel> {
  void _setClaimStatus(ClaimRecord claim, ClaimStatus status, String note) {
    widget.repository.updateClaimStatus(
      claimId: claim.id,
      status: status,
      statusNote: note,
    );
  }

  Future<void> _exportClaim(ClaimRecord claim) async {
    final booking = widget.repository.bookingById(claim.bookingId);
    final payload = ClaimAssistEngine.exportText(
      claim: claim,
      booking: booking,
    );
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Export to Existing Workflow'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Use this payload for your payer portal, clearing-house import, or legacy billing handoff.',
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FAFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppPalette.atlanticSand),
                ),
                child: SelectableText(
                  payload,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              Clipboard.setData(ClipboardData(text: payload));
              Navigator.pop(dialogContext);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Claim export copied to clipboard.'),
                ),
              );
            },
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy Export Payload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = widget.repository.dashboardMetrics(
      widget.selectedPractice.id,
      DateTime.now(),
    );
    final claims = metrics['claimCount'] ?? 0;
    final simulatedOutstanding = claims * 220;
    final claimList = widget.repository.claimsForPractice(
      widget.selectedPractice.id,
    );
    final rejectedClaims = widget.repository.rejectedClaimsForPractice(
      widget.selectedPractice.id,
    );
    final overdueClaims = widget.repository.overdueClaimsForPractice(
      widget.selectedPractice.id,
    );
    final submitted = claimList
        .where((claim) => claim.status == ClaimStatus.submitted)
        .length;
    final denied = claimList
        .where((claim) => claim.status == ClaimStatus.denied)
        .length;
    final paid = claimList
        .where((claim) => claim.status == ClaimStatus.paid)
        .length;

    return StreamBuilder<void>(
      stream: widget.repository.changes,
      builder: (context, snapshot) => ListView(
        key: const ValueKey('billingHub'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          if (snapshot.connectionState == ConnectionState.waiting)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          _sectionCard(
            title: 'Revenue & Billing Control',
            subtitle:
                'Claims quality and accounts receivable view for finance staff.',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _infoTile('Claims Ready', '$claims'),
                _infoTile('Outstanding AR', 'R$simulatedOutstanding'),
                _infoTile(
                  'Collection Priority',
                  simulatedOutstanding > 0 ? 'High' : 'Normal',
                ),
                _infoTile('Submitted', '$submitted'),
                _infoTile('Denied', '$denied'),
                _infoTile('Paid', '$paid'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Claims Worklist',
            subtitle:
                'Move each claim through Draft -> Submitted -> Paid (or Denied).',
            child: claimList.isEmpty
                ? const Text('No claims yet. Complete a visit to create one.')
                : Column(
                    children: claimList
                        .map(
                          (claim) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FBFF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppPalette.atlanticSand,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Claim ${claim.id.substring(claim.id.length - 6)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _claimStatusChip(claim.status),
                                    const Spacer(),
                                    Text(
                                      'R${claim.claimAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  claim.statusNote ?? 'No status note.',
                                  style: const TextStyle(
                                    color: Color(0xFF5B6E89),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'ICD-10 ${claim.icd10Code} • Tariff ${claim.tariffCode}',
                                  style: const TextStyle(
                                    color: Color(0xFF2F5D86),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  claim.validationSummary,
                                  style: TextStyle(
                                    color: claim.validationPassed
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFB3261E),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _setClaimStatus(
                                        claim,
                                        ClaimStatus.submitted,
                                        'Submitted to payer / clearing house.',
                                      ),
                                      child: const Text('Submit'),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => _setClaimStatus(
                                        claim,
                                        ClaimStatus.paid,
                                        'Payment reconciled in accounts.',
                                      ),
                                      child: const Text('Mark Paid'),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => _setClaimStatus(
                                        claim,
                                        ClaimStatus.denied,
                                        'Denied: needs coding or documentation fix.',
                                      ),
                                      child: const Text('Mark Denied'),
                                    ),
                                    FilledButton.tonalIcon(
                                      onPressed: () => _exportClaim(claim),
                                      icon: const Icon(
                                        Icons.upload_file_outlined,
                                      ),
                                      label: const Text('Export'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Rejected Claims Triage',
            subtitle: 'Reason-level queue to resolve denials faster.',
            child: rejectedClaims.isEmpty
                ? const Text('No rejected claims in queue.')
                : Column(
                    children: rejectedClaims
                        .take(5)
                        .map(
                          (claim) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.error_outline,
                              color: Color(0xFFCC3F3F),
                            ),
                            title: Text(
                              'Claim ${claim.id.substring(claim.id.length - 6)} • R${claim.claimAmount.toStringAsFixed(0)}',
                            ),
                            subtitle: Text(
                              claim.statusNote ?? claim.validationSummary,
                            ),
                            trailing: Text(
                              DateFormat('dd MMM').format(claim.createdAt),
                              style: const TextStyle(
                                color: AppPalette.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Overdue Payment Watchlist',
            subtitle: 'Claims older than 14 days and not marked paid.',
            child: overdueClaims.isEmpty
                ? const Text('No overdue claims currently.')
                : Column(
                    children: overdueClaims
                        .take(5)
                        .map(
                          (claim) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.schedule_outlined,
                              color: AppPalette.secondary,
                            ),
                            title: Text(
                              'Claim ${claim.id.substring(claim.id.length - 6)} • ${DateTime.now().difference(claim.createdAt).inDays} days',
                            ),
                            subtitle: Text(
                              'Status: ${claim.status.name} • ${claim.statusNote ?? 'Awaiting settlement'}',
                            ),
                            trailing: Text(
                              'R${claim.claimAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Collections Playbook',
            subtitle:
                '3-day pre-visit benefit check, same-day collection, 30/60/90 day AR follow-up.',
            child: const Text(
              'This workflow directly addresses common practice cashflow pressure.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _claimStatusChip(ClaimStatus status) {
    late final String label;
    late final Color color;
    switch (status) {
      case ClaimStatus.draft:
        label = 'Draft';
        color = const Color(0xFF7E6AE6);
        break;
      case ClaimStatus.submitted:
        label = 'Submitted';
        color = const Color(0xFF1A86D9);
        break;
      case ClaimStatus.denied:
        label = 'Denied';
        color = const Color(0xFFCC3F3F);
        break;
      case ClaimStatus.paid:
        label = 'Paid';
        color = const Color(0xFF1F9C64);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class InventoryHubPanel extends StatelessWidget {
  const InventoryHubPanel({super.key, required this.selectedPractice});

  final Practice selectedPractice;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('inventoryHub'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: const [_StockSnapshotCard()],
    );
  }
}

class ReportsHubPanel extends StatelessWidget {
  const ReportsHubPanel({
    super.key,
    required this.repository,
    required this.selectedPractice,
  });

  final EyecareRepository repository;
  final Practice selectedPractice;

  @override
  Widget build(BuildContext context) {
    final metrics = repository.dashboardMetrics(
      selectedPractice.id,
      DateTime.now(),
    );
    final claims = repository.claimsForPractice(selectedPractice.id);
    final activities = repository.staffActivitiesForPractice(
      selectedPractice.id,
    );
    final draft = claims.where((c) => c.status == ClaimStatus.draft).length;
    final submitted = claims
        .where((c) => c.status == ClaimStatus.submitted)
        .length;
    final denied = claims.where((c) => c.status == ClaimStatus.denied).length;
    final paid = claims.where((c) => c.status == ClaimStatus.paid).length;
    final chartData = <String, double>{
      'Diary': (metrics['todayBookings'] ?? 0).toDouble(),
      'Claims': (metrics['claimCount'] ?? 0).toDouble(),
      'Files': (metrics['fileCount'] ?? 0).toDouble(),
      'NoShows': (metrics['noShows'] ?? 0).toDouble(),
    };

    return ListView(
      key: const ValueKey('reportsHub'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        _sectionCard(
          title: 'Executive Snapshot',
          subtitle: 'What the owner needs in under 30 seconds.',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _infoTile('No-Show Risk', '${metrics['noShows']}'),
              _infoTile('Daily Throughput', '${metrics['todayBookings']}'),
              _infoTile('Claim Pipeline', '${metrics['claimCount']}'),
              _infoTile('Record Compliance', '${metrics['fileCount']} files'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Operations Trend Visual',
          subtitle: 'Compact chart for daily operational pulse.',
          child: _MiniBarChart(data: chartData),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Claim Lifecycle Visual',
          subtitle: 'Shows how many claims are stuck vs progressing.',
          child: _MiniBarChart(
            data: <String, double>{
              'Draft': draft.toDouble(),
              'Submitted': submitted.toDouble(),
              'Denied': denied.toDouble(),
              'Paid': paid.toDouble(),
            },
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Audit Trail & Staff Activity',
          subtitle:
              'Timestamped operational events to build trust and accountability.',
          child: activities.isEmpty
              ? const Text('No staff activity logged yet.')
              : Column(
                  children: activities
                      .map(
                        (activity) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.history_toggle_off_outlined,
                            color: AppPalette.primary,
                          ),
                          title: Text('${activity.actor} • ${activity.action}'),
                          subtitle: Text(activity.details),
                          trailing: Text(
                            DateFormat(
                              'dd MMM HH:mm',
                            ).format(activity.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppPalette.textMuted,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _StockSnapshotCard extends StatelessWidget {
  const _StockSnapshotCard();

  @override
  Widget build(BuildContext context) {
    return _sectionCard(
      title: 'Optical Stock Snapshot',
      subtitle: 'Starter module for frame/lens operations.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Frames low stock: 6'),
          Text('Contact lens boxes low stock: 4'),
          Text('Top movement SKU: BlueLight-Pro Lens'),
          SizedBox(height: 8),
          Text(
            'Next step: barcode scan-in/out + supplier reorder flow.',
            style: TextStyle(color: Color(0xFF5C6C84)),
          ),
        ],
      ),
    );
  }
}

Widget _sectionCard({
  required String title,
  required String subtitle,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppPalette.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x100C3059),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppPalette.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

Widget _infoTile(String label, String value) {
  return Container(
    width: 180,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF1F7FC), Color(0xFFE7F1F8)],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppPalette.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppPalette.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppPalette.textPrimary,
          ),
        ),
      ],
    ),
  );
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart({required this.data});

  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Text('No data available.');
    }
    final max = data.values.fold<double>(
      0,
      (prev, val) => val > prev ? val : prev,
    );
    final safeMax = max <= 0 ? 1.0 : max;
    final entries = data.entries.toList(growable: false);

    return Column(
      children: entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Color(0xFF5A6980),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: entry.value / safeMax,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFE6EEF9),
                        valueColor: const AlwaysStoppedAnimation(
                          AppPalette.chart,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    entry.value.toInt().toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ClaimDialogResult {
  const _ClaimDialogResult({
    required this.clinicalFindings,
    required this.visitSummary,
    required this.claimAmount,
    required this.icd10Code,
    required this.tariffCode,
    required this.validationIssues,
  });

  final String clinicalFindings;
  final String visitSummary;
  final double claimAmount;
  final String icd10Code;
  final String tariffCode;
  final List<String> validationIssues;
}
