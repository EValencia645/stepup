/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the StepRecord type in your schema. */
class StepRecord extends amplify_core.Model {
  static const classType = const _StepRecordModelType();
  final String id;
  final int? _stepCount;
  final amplify_core.TemporalDate? _date;
  final String? _notes;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  StepRecordModelIdentifier get modelIdentifier {
      return StepRecordModelIdentifier(
        id: id
      );
  }
  
  int get stepCount {
    try {
      return _stepCount!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDate get date {
    try {
      return _date!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get notes {
    return _notes;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const StepRecord._internal({required this.id, required stepCount, required date, notes, createdAt, updatedAt}): _stepCount = stepCount, _date = date, _notes = notes, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory StepRecord({String? id, required int stepCount, required amplify_core.TemporalDate date, String? notes}) {
    return StepRecord._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      stepCount: stepCount,
      date: date,
      notes: notes);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StepRecord &&
      id == other.id &&
      _stepCount == other._stepCount &&
      _date == other._date &&
      _notes == other._notes;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("StepRecord {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("stepCount=" + (_stepCount != null ? _stepCount!.toString() : "null") + ", ");
    buffer.write("date=" + (_date != null ? _date!.format() : "null") + ", ");
    buffer.write("notes=" + "$_notes" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  StepRecord copyWith({int? stepCount, amplify_core.TemporalDate? date, String? notes}) {
    return StepRecord._internal(
      id: id,
      stepCount: stepCount ?? this.stepCount,
      date: date ?? this.date,
      notes: notes ?? this.notes);
  }
  
  StepRecord copyWithModelFieldValues({
    ModelFieldValue<int>? stepCount,
    ModelFieldValue<amplify_core.TemporalDate>? date,
    ModelFieldValue<String?>? notes
  }) {
    return StepRecord._internal(
      id: id,
      stepCount: stepCount == null ? this.stepCount : stepCount.value,
      date: date == null ? this.date : date.value,
      notes: notes == null ? this.notes : notes.value
    );
  }
  
  StepRecord.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _stepCount = (json['stepCount'] as num?)?.toInt(),
      _date = json['date'] != null ? amplify_core.TemporalDate.fromString(json['date']) : null,
      _notes = json['notes'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'stepCount': _stepCount, 'date': _date?.format(), 'notes': _notes, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'stepCount': _stepCount,
    'date': _date,
    'notes': _notes,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<StepRecordModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<StepRecordModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final STEPCOUNT = amplify_core.QueryField(fieldName: "stepCount");
  static final DATE = amplify_core.QueryField(fieldName: "date");
  static final NOTES = amplify_core.QueryField(fieldName: "notes");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "StepRecord";
    modelSchemaDefinition.pluralName = "StepRecords";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: StepRecord.STEPCOUNT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: StepRecord.DATE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.date)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: StepRecord.NOTES,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _StepRecordModelType extends amplify_core.ModelType<StepRecord> {
  const _StepRecordModelType();
  
  @override
  StepRecord fromJson(Map<String, dynamic> jsonData) {
    return StepRecord.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'StepRecord';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [StepRecord] in your schema.
 */
class StepRecordModelIdentifier implements amplify_core.ModelIdentifier<StepRecord> {
  final String id;

  /** Create an instance of StepRecordModelIdentifier using [id] the primary key. */
  const StepRecordModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'StepRecordModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is StepRecordModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}