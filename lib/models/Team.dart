// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class Team extends amplify_core.Model {
  static const classType = _TeamModelType();
  final String id;
  final String? _name;
  final String? _code;
  final String? _createdBy;
  final amplify_core.TemporalDate? _startDate;
  final amplify_core.TemporalDate? _endDate;
  final int? _goalSteps;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;

  TeamModelIdentifier get modelIdentifier => TeamModelIdentifier(id: id);

  String get name {
    try { return _name!; } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString());
    }
  }

  String get code {
    try { return _code!; } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString());
    }
  }

  String get createdBy {
    try { return _createdBy!; } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString());
    }
  }

  amplify_core.TemporalDate get startDate {
    try { return _startDate!; } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString());
    }
  }

  amplify_core.TemporalDate get endDate {
    try { return _endDate!; } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString());
    }
  }

  int? get goalSteps => _goalSteps;
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const Team._internal({
    required this.id,
    required name,
    required code,
    required createdBy,
    required startDate,
    required endDate,
    goalSteps,
    createdAt,
    updatedAt,
  })  : _name = name,
        _code = code,
        _createdBy = createdBy,
        _startDate = startDate,
        _endDate = endDate,
        _goalSteps = goalSteps,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory Team({
    String? id,
    required String name,
    required String code,
    required String createdBy,
    required amplify_core.TemporalDate startDate,
    required amplify_core.TemporalDate endDate,
    int? goalSteps,
  }) {
    return Team._internal(
      id: id ?? amplify_core.UUID.getUUID(),
      name: name,
      code: code,
      createdBy: createdBy,
      startDate: startDate,
      endDate: endDate,
      goalSteps: goalSteps,
    );
  }

  Team copyWith({
    String? name,
    String? code,
    String? createdBy,
    amplify_core.TemporalDate? startDate,
    amplify_core.TemporalDate? endDate,
    int? goalSteps,
  }) {
    return Team._internal(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      createdBy: createdBy ?? this.createdBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goalSteps: goalSteps ?? this.goalSteps,
    );
  }

  Team.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _name = json['name'],
        _code = json['code'],
        _createdBy = json['createdBy'],
        _startDate = json['startDate'] != null
            ? amplify_core.TemporalDate.fromString(json['startDate'])
            : null,
        _endDate = json['endDate'] != null
            ? amplify_core.TemporalDate.fromString(json['endDate'])
            : null,
        _goalSteps = (json['goalSteps'] as num?)?.toInt(),
        _createdAt = json['createdAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
            : null,
        _updatedAt = json['updatedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': _name,
        'code': _code,
        'createdBy': _createdBy,
        'startDate': _startDate?.format(),
        'endDate': _endDate?.format(),
        'goalSteps': _goalSteps,
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format(),
      };

  Map<String, Object?> toMap() => {
        'id': id,
        'name': _name,
        'code': _code,
        'createdBy': _createdBy,
        'startDate': _startDate,
        'endDate': _endDate,
        'goalSteps': _goalSteps,
        'createdAt': _createdAt,
        'updatedAt': _updatedAt,
      };

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Team &&
        id == other.id &&
        _name == other._name &&
        _code == other._code &&
        _createdBy == other._createdBy &&
        _startDate == other._startDate &&
        _endDate == other._endDate &&
        _goalSteps == other._goalSteps;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    return 'Team {id=$id, name=$_name, code=$_code, createdBy=$_createdBy, '
        'startDate=${_startDate?.format()}, endDate=${_endDate?.format()}, '
        'goalSteps=$_goalSteps}';
  }

  static final amplify_core.QueryModelIdentifier<TeamModelIdentifier>
      MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<TeamModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: 'id');
  static final NAME = amplify_core.QueryField(fieldName: 'name');
  static final CODE = amplify_core.QueryField(fieldName: 'code');
  static final CREATEDBY = amplify_core.QueryField(fieldName: 'createdBy');
  static final STARTDATE = amplify_core.QueryField(fieldName: 'startDate');
  static final ENDDATE = amplify_core.QueryField(fieldName: 'endDate');
  static final GOALSTEPS = amplify_core.QueryField(fieldName: 'goalSteps');

  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = 'Team';
      modelSchemaDefinition.pluralName = 'Teams';

      modelSchemaDefinition.authRules = [
        amplify_core.AuthRule(
          authStrategy: amplify_core.AuthStrategy.OWNER,
          ownerField: 'owner',
          identityClaim: 'cognito:username',
          provider: amplify_core.AuthRuleProvider.USERPOOLS,
          operations: const [
            amplify_core.ModelOperation.CREATE,
            amplify_core.ModelOperation.UPDATE,
            amplify_core.ModelOperation.DELETE,
            amplify_core.ModelOperation.READ,
          ],
        ),
        amplify_core.AuthRule(
          authStrategy: amplify_core.AuthStrategy.PRIVATE,
          operations: const [amplify_core.ModelOperation.READ],
        ),
      ];

      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
        key: Team.NAME,
        isRequired: true,
        ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string),
      ));
      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
        key: Team.CODE,
        isRequired: true,
        ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string),
      ));
      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
        key: Team.CREATEDBY,
        isRequired: true,
        ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string),
      ));
      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
        key: Team.STARTDATE,
        isRequired: true,
        ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.date),
      ));
      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
        key: Team.ENDDATE,
        isRequired: true,
        ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.date),
      ));
      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
        key: Team.GOALSTEPS,
        isRequired: false,
        ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int),
      ));
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.nonQueryField(
          fieldName: 'createdAt',
          isRequired: false,
          isReadOnly: true,
          ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.nonQueryField(
          fieldName: 'updatedAt',
          isRequired: false,
          isReadOnly: true,
          ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime),
        ),
      );
    },
  );
}

class _TeamModelType extends amplify_core.ModelType<Team> {
  const _TeamModelType();

  @override
  Team fromJson(Map<String, dynamic> jsonData) => Team.fromJson(jsonData);

  @override
  String modelName() => 'Team';
}

class TeamModelIdentifier
    implements amplify_core.ModelIdentifier<Team> {
  final String id;
  const TeamModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => {'id': id};

  @override
  List<Map<String, dynamic>> serializeAsList() =>
      serializeAsMap().entries.map((e) => {e.key: e.value}).toList();

  @override
  String serializeAsString() => id;

  @override
  String toString() => 'TeamModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamModelIdentifier && id == other.id);

  @override
  int get hashCode => id.hashCode;
}
