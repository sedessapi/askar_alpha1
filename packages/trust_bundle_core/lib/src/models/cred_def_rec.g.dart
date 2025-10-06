// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cred_def_rec.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCredDefRecCollection on Isar {
  IsarCollection<CredDefRec> get credDefRecs => this.collection();
}

const CredDefRecSchema = CollectionSchema(
  name: r'CredDefRec',
  id: 5753771173727725299,
  properties: {
    r'content': PropertySchema(
      id: 0,
      name: r'content',
      type: IsarType.string,
    ),
    r'credDefId': PropertySchema(
      id: 1,
      name: r'credDefId',
      type: IsarType.string,
    )
  },
  estimateSize: _credDefRecEstimateSize,
  serialize: _credDefRecSerialize,
  deserialize: _credDefRecDeserialize,
  deserializeProp: _credDefRecDeserializeProp,
  idName: r'id',
  indexes: {
    r'credDefId': IndexSchema(
      id: -9011857593208979475,
      name: r'credDefId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'credDefId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _credDefRecGetId,
  getLinks: _credDefRecGetLinks,
  attach: _credDefRecAttach,
  version: '3.1.0+1',
);

int _credDefRecEstimateSize(
  CredDefRec object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.content.length * 3;
  bytesCount += 3 + object.credDefId.length * 3;
  return bytesCount;
}

void _credDefRecSerialize(
  CredDefRec object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.content);
  writer.writeString(offsets[1], object.credDefId);
}

CredDefRec _credDefRecDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CredDefRec();
  object.content = reader.readString(offsets[0]);
  object.credDefId = reader.readString(offsets[1]);
  object.id = id;
  return object;
}

P _credDefRecDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _credDefRecGetId(CredDefRec object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _credDefRecGetLinks(CredDefRec object) {
  return [];
}

void _credDefRecAttach(IsarCollection<dynamic> col, Id id, CredDefRec object) {
  object.id = id;
}

extension CredDefRecByIndex on IsarCollection<CredDefRec> {
  Future<CredDefRec?> getByCredDefId(String credDefId) {
    return getByIndex(r'credDefId', [credDefId]);
  }

  CredDefRec? getByCredDefIdSync(String credDefId) {
    return getByIndexSync(r'credDefId', [credDefId]);
  }

  Future<bool> deleteByCredDefId(String credDefId) {
    return deleteByIndex(r'credDefId', [credDefId]);
  }

  bool deleteByCredDefIdSync(String credDefId) {
    return deleteByIndexSync(r'credDefId', [credDefId]);
  }

  Future<List<CredDefRec?>> getAllByCredDefId(List<String> credDefIdValues) {
    final values = credDefIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'credDefId', values);
  }

  List<CredDefRec?> getAllByCredDefIdSync(List<String> credDefIdValues) {
    final values = credDefIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'credDefId', values);
  }

  Future<int> deleteAllByCredDefId(List<String> credDefIdValues) {
    final values = credDefIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'credDefId', values);
  }

  int deleteAllByCredDefIdSync(List<String> credDefIdValues) {
    final values = credDefIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'credDefId', values);
  }

  Future<Id> putByCredDefId(CredDefRec object) {
    return putByIndex(r'credDefId', object);
  }

  Id putByCredDefIdSync(CredDefRec object, {bool saveLinks = true}) {
    return putByIndexSync(r'credDefId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCredDefId(List<CredDefRec> objects) {
    return putAllByIndex(r'credDefId', objects);
  }

  List<Id> putAllByCredDefIdSync(List<CredDefRec> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'credDefId', objects, saveLinks: saveLinks);
  }
}

extension CredDefRecQueryWhereSort
    on QueryBuilder<CredDefRec, CredDefRec, QWhere> {
  QueryBuilder<CredDefRec, CredDefRec, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CredDefRecQueryWhere
    on QueryBuilder<CredDefRec, CredDefRec, QWhereClause> {
  QueryBuilder<CredDefRec, CredDefRec, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<CredDefRec, CredDefRec, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterWhereClause> idBetween(
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

  QueryBuilder<CredDefRec, CredDefRec, QAfterWhereClause> credDefIdEqualTo(
      String credDefId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'credDefId',
        value: [credDefId],
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterWhereClause> credDefIdNotEqualTo(
      String credDefId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credDefId',
              lower: [],
              upper: [credDefId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credDefId',
              lower: [credDefId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credDefId',
              lower: [credDefId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credDefId',
              lower: [],
              upper: [credDefId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CredDefRecQueryFilter
    on QueryBuilder<CredDefRec, CredDefRec, QFilterCondition> {
  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> credDefIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credDefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition>
      credDefIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'credDefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> credDefIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'credDefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> credDefIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'credDefId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition>
      credDefIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'credDefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> credDefIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'credDefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> credDefIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'credDefId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> credDefIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'credDefId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition>
      credDefIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credDefId',
        value: '',
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition>
      credDefIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'credDefId',
        value: '',
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CredDefRec, CredDefRec, QAfterFilterCondition> idBetween(
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
}

extension CredDefRecQueryObject
    on QueryBuilder<CredDefRec, CredDefRec, QFilterCondition> {}

extension CredDefRecQueryLinks
    on QueryBuilder<CredDefRec, CredDefRec, QFilterCondition> {}

extension CredDefRecQuerySortBy
    on QueryBuilder<CredDefRec, CredDefRec, QSortBy> {
  QueryBuilder<CredDefRec, CredDefRec, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterSortBy> sortByCredDefId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credDefId', Sort.asc);
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterSortBy> sortByCredDefIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credDefId', Sort.desc);
    });
  }
}

extension CredDefRecQuerySortThenBy
    on QueryBuilder<CredDefRec, CredDefRec, QSortThenBy> {
  QueryBuilder<CredDefRec, CredDefRec, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterSortBy> thenByCredDefId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credDefId', Sort.asc);
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterSortBy> thenByCredDefIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credDefId', Sort.desc);
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension CredDefRecQueryWhereDistinct
    on QueryBuilder<CredDefRec, CredDefRec, QDistinct> {
  QueryBuilder<CredDefRec, CredDefRec, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CredDefRec, CredDefRec, QDistinct> distinctByCredDefId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'credDefId', caseSensitive: caseSensitive);
    });
  }
}

extension CredDefRecQueryProperty
    on QueryBuilder<CredDefRec, CredDefRec, QQueryProperty> {
  QueryBuilder<CredDefRec, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CredDefRec, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<CredDefRec, String, QQueryOperations> credDefIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credDefId');
    });
  }
}
