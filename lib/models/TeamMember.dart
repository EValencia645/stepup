// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class TeamMember extends amplify_core.Model {
  static const classType = _TeamMemberModelType();
  final String id;
  final String? _teamId;
  final String? _userName;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;

  TeamMemberModelIdentifier get modelIdentifier =>
      TeamMemberModelIdentifier(id: id);

  String get teamId {
    try { return _teamId!; } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString());
    }
  }

  String get userName {
    try { return _userName!; } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
        amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
        recoverySuggestion: amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
        underlyingException: e.toString());
    }
  }

  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const TeamMember._internal({
    required this.id,
    required teamId,
    required userName,
    createdAt,
    updatedAt,
  })  : _teamId = teamId,
        _userName = userName,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory TeamMember({
    String? id,
    required String teamId,
    required String userName,
  }) {
    return TeamMember._internal(
      id: id ?? amplify_core.UUID.getUUID(),
      teamId: teamId,
      userName: userName,
    );
  }

  TeamMember copyWith({String? teamId, String? userName}) {
    return TeamMember._internal(
      id: id,
      teamId: teamId ?? this.teamId,
      userName: userName ?? this.userName,
    );
  }

  TeamMember.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _teamId = json['teamId'],
        _userName = json['userName'],
        _createdAt = json['createdAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
            : null,
        _updatedAt = json['updatedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamId': _teamId,
        'userName': _userName,
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format(),
      };

  Map<String, Object?> toMap() => {
        'id': id,
        'teamId': _teamId,
        'userName': _userName,
        'createdAt': _createdAt,
        'updatedAt': _updatedAt,
      };

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TeamMember &&
        id == other.id &&
        _teamId == other._teamId &&
        _userName == other._userName;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() =>
      'TeamMember {id=$id, teamId=$_teamId, userName=$_userName}';

  static final amplify_core.QueryModelIdentifier<TeamMemberModelIdentifier>
      MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<TeamMemberModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: 'id');
  static final TEAMID = amplify_core.QueryField(fieldName: 'teamId');
  static final USERNAME = amplify_core.QueryField(fieldName: 'userName');

  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = 'TeamMember';
      modelSchemaDefinition.pluralName = 'TeamMembers';

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
        key: TeamMember.TEAMID,
        isRequired: true,
        ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string),
      ));
      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
        key: TeamMember.USERNAME,
        isRequired: true,
        ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string),
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

class _TeamMemberModelType extends amplify_core.ModelType<TeamMember> {
  const _TeamMemberModelType();

  @override
  TeamMember fromJson(Map<String, dynamic> jsonData) =>
      TeamMember.fromJson(jsonData);

  @override
  String modelName() => 'TeamMember';
}

class TeamMemberModelIdentifier
    implements amplify_core.ModelIdentifier<TeamMember> {
  final String id;
  const TeamMemberModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => {'id': id};

  @override
  List<Map<String, dynamic>> serializeAsList() =>
      serializeAsMap().entries.map((e) => {e.key: e.value}).toList();

  @override
  String serializeAsString() => id;

  @override
  String toString() => 'TeamMemberModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamMemberModelIdentifier && id == other.id);

  @override
  int get hashCode => id.hashCode;
}
