// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNoteCollection on Isar {
  IsarCollection<Note> get notes => this.collection();
}

const NoteSchema = CollectionSchema(
  name: r'Note',
  id: 6284318083599466921,
  properties: {
    r'additionalNotes': PropertySchema(
      id: 0,
      name: r'additionalNotes',
      type: IsarType.string,
    ),
    r'fileName': PropertySchema(
      id: 1,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'frontSprocket': PropertySchema(
      id: 2,
      name: r'frontSprocket',
      type: IsarType.string,
    ),
    r'mainJet': PropertySchema(
      id: 3,
      name: r'mainJet',
      type: IsarType.string,
    ),
    r'needlePosition': PropertySchema(
      id: 4,
      name: r'needlePosition',
      type: IsarType.string,
    ),
    r'pilotJet': PropertySchema(
      id: 5,
      name: r'pilotJet',
      type: IsarType.string,
    ),
    r'rearSprocket': PropertySchema(
      id: 6,
      name: r'rearSprocket',
      type: IsarType.string,
    ),
    r'session': PropertySchema(
      id: 7,
      name: r'session',
      type: IsarType.string,
    )
  },
  estimateSize: _noteEstimateSize,
  serialize: _noteSerialize,
  deserialize: _noteDeserialize,
  deserializeProp: _noteDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _noteGetId,
  getLinks: _noteGetLinks,
  attach: _noteAttach,
  version: '3.1.0+1',
);

int _noteEstimateSize(
  Note object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.additionalNotes.length * 3;
  bytesCount += 3 + object.fileName.length * 3;
  bytesCount += 3 + object.frontSprocket.length * 3;
  bytesCount += 3 + object.mainJet.length * 3;
  bytesCount += 3 + object.needlePosition.length * 3;
  bytesCount += 3 + object.pilotJet.length * 3;
  bytesCount += 3 + object.rearSprocket.length * 3;
  bytesCount += 3 + object.session.length * 3;
  return bytesCount;
}

void _noteSerialize(
  Note object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.additionalNotes);
  writer.writeString(offsets[1], object.fileName);
  writer.writeString(offsets[2], object.frontSprocket);
  writer.writeString(offsets[3], object.mainJet);
  writer.writeString(offsets[4], object.needlePosition);
  writer.writeString(offsets[5], object.pilotJet);
  writer.writeString(offsets[6], object.rearSprocket);
  writer.writeString(offsets[7], object.session);
}

Note _noteDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Note();
  object.additionalNotes = reader.readString(offsets[0]);
  object.fileName = reader.readString(offsets[1]);
  object.frontSprocket = reader.readString(offsets[2]);
  object.id = id;
  object.mainJet = reader.readString(offsets[3]);
  object.needlePosition = reader.readString(offsets[4]);
  object.pilotJet = reader.readString(offsets[5]);
  object.rearSprocket = reader.readString(offsets[6]);
  object.session = reader.readString(offsets[7]);
  return object;
}

P _noteDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _noteGetId(Note object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _noteGetLinks(Note object) {
  return [];
}

void _noteAttach(IsarCollection<dynamic> col, Id id, Note object) {
  object.id = id;
}

extension NoteQueryWhereSort on QueryBuilder<Note, Note, QWhere> {
  QueryBuilder<Note, Note, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NoteQueryWhere on QueryBuilder<Note, Note, QWhereClause> {
  QueryBuilder<Note, Note, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NoteQueryFilter on QueryBuilder<Note, Note, QFilterCondition> {
  QueryBuilder<Note, Note, QAfterFilterCondition> additionalNotesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> additionalNotesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'additionalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> additionalNotesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'additionalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> additionalNotesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'additionalNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> additionalNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'additionalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> additionalNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'additionalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> additionalNotesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'additionalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> additionalNotesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'additionalNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> additionalNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> additionalNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'additionalNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> fileNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> fileNameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> fileNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> frontSprocketEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frontSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> frontSprocketGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frontSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> frontSprocketLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frontSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> frontSprocketBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frontSprocket',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> frontSprocketStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'frontSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> frontSprocketEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'frontSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> frontSprocketContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'frontSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> frontSprocketMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'frontSprocket',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> frontSprocketIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frontSprocket',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> frontSprocketIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'frontSprocket',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> mainJetEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mainJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> mainJetGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mainJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> mainJetLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mainJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> mainJetBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mainJet',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> mainJetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mainJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> mainJetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mainJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> mainJetContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mainJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> mainJetMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mainJet',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> mainJetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mainJet',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> mainJetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mainJet',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> needlePositionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needlePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> needlePositionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'needlePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> needlePositionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'needlePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> needlePositionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'needlePosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> needlePositionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'needlePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> needlePositionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'needlePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> needlePositionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'needlePosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> needlePositionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'needlePosition',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> needlePositionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needlePosition',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> needlePositionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'needlePosition',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> pilotJetEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pilotJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> pilotJetGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pilotJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> pilotJetLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pilotJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> pilotJetBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pilotJet',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> pilotJetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pilotJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> pilotJetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pilotJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> pilotJetContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pilotJet',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> pilotJetMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pilotJet',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> pilotJetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pilotJet',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> pilotJetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pilotJet',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rearSprocketEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rearSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rearSprocketGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rearSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rearSprocketLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rearSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rearSprocketBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rearSprocket',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rearSprocketStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rearSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rearSprocketEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rearSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rearSprocketContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rearSprocket',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rearSprocketMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rearSprocket',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rearSprocketIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rearSprocket',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rearSprocketIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rearSprocket',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sessionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'session',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sessionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'session',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sessionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'session',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sessionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'session',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sessionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'session',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sessionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'session',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sessionContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'session',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sessionMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'session',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sessionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'session',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sessionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'session',
        value: '',
      ));
    });
  }
}

extension NoteQueryObject on QueryBuilder<Note, Note, QFilterCondition> {}

extension NoteQueryLinks on QueryBuilder<Note, Note, QFilterCondition> {}

extension NoteQuerySortBy on QueryBuilder<Note, Note, QSortBy> {
  QueryBuilder<Note, Note, QAfterSortBy> sortByAdditionalNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalNotes', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByAdditionalNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalNotes', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByFrontSprocket() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frontSprocket', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByFrontSprocketDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frontSprocket', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByMainJet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainJet', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByMainJetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainJet', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByNeedlePosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needlePosition', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByNeedlePositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needlePosition', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByPilotJet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pilotJet', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByPilotJetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pilotJet', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByRearSprocket() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rearSprocket', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByRearSprocketDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rearSprocket', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortBySession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'session', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortBySessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'session', Sort.desc);
    });
  }
}

extension NoteQuerySortThenBy on QueryBuilder<Note, Note, QSortThenBy> {
  QueryBuilder<Note, Note, QAfterSortBy> thenByAdditionalNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalNotes', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByAdditionalNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalNotes', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByFrontSprocket() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frontSprocket', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByFrontSprocketDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frontSprocket', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByMainJet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainJet', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByMainJetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainJet', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByNeedlePosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needlePosition', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByNeedlePositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needlePosition', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByPilotJet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pilotJet', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByPilotJetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pilotJet', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByRearSprocket() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rearSprocket', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByRearSprocketDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rearSprocket', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenBySession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'session', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenBySessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'session', Sort.desc);
    });
  }
}

extension NoteQueryWhereDistinct on QueryBuilder<Note, Note, QDistinct> {
  QueryBuilder<Note, Note, QDistinct> distinctByAdditionalNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'additionalNotes',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByFileName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByFrontSprocket(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frontSprocket',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByMainJet(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mainJet', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByNeedlePosition(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needlePosition',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByPilotJet(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pilotJet', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByRearSprocket(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rearSprocket', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctBySession(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'session', caseSensitive: caseSensitive);
    });
  }
}

extension NoteQueryProperty on QueryBuilder<Note, Note, QQueryProperty> {
  QueryBuilder<Note, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> additionalNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'additionalNotes');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> frontSprocketProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frontSprocket');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> mainJetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mainJet');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> needlePositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needlePosition');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> pilotJetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pilotJet');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> rearSprocketProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rearSprocket');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> sessionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'session');
    });
  }
}
