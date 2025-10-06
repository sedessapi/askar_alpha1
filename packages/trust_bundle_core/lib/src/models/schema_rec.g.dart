// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema_rec.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSchemaRecCollection on Isar {
  IsarCollection<SchemaRec> get schemaRecs => this.collection();
}

const SchemaRecSchema = CollectionSchema(
  name: r'SchemaRec',
  id: -5944966496022818641,
  properties: {
    r'content': PropertySchema(
      id: 0,
      name: r'content',
      type: IsarType.string,
    ),
    r'schemaId': PropertySchema(
      id: 1,
      name: r'schemaId',
      type: IsarType.string,
    )
  },
  estimateSize: _schemaRecEstimateSize,
  serialize: _schemaRecSerialize,
  deserialize: _schemaRecDeserialize,
  deserializeProp: _schemaRecDeserializeProp,
  idName: r'id',
  indexes: {
    r'schemaId': IndexSchema(
      id: 6831641797449313509,
      name: r'schemaId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'schemaId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _schemaRecGetId,
  getLinks: _schemaRecGetLinks,
  attach: _schemaRecAttach,
  version: '3.1.0+1',
);

int _schemaRecEstimateSize(
  SchemaRec object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.content.length * 3;
  bytesCount += 3 + object.schemaId.length * 3;
  return bytesCount;
}

void _schemaRecSerialize(
  SchemaRec object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.content);
  writer.writeString(offsets[1], object.schemaId);
}

SchemaRec _schemaRecDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SchemaRec();
  object.content = reader.readString(offsets[0]);
  object.id = id;
  object.schemaId = reader.readString(offsets[1]);
  return object;
}

P _schemaRecDeserializeProp<P>(
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

Id _schemaRecGetId(SchemaRec object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _schemaRecGetLinks(SchemaRec object) {
  return [];
}

void _schemaRecAttach(IsarCollection<dynamic> col, Id id, SchemaRec object) {
  object.id = id;
}

extension SchemaRecByIndex on IsarCollection<SchemaRec> {
  Future<SchemaRec?> getBySchemaId(String schemaId) {
    return getByIndex(r'schemaId', [schemaId]);
  }

  SchemaRec? getBySchemaIdSync(String schemaId) {
    return getByIndexSync(r'schemaId', [schemaId]);
  }

  Future<bool> deleteBySchemaId(String schemaId) {
    return deleteByIndex(r'schemaId', [schemaId]);
  }

  bool deleteBySchemaIdSync(String schemaId) {
    return deleteByIndexSync(r'schemaId', [schemaId]);
  }

  Future<List<SchemaRec?>> getAllBySchemaId(List<String> schemaIdValues) {
    final values = schemaIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'schemaId', values);
  }

  List<SchemaRec?> getAllBySchemaIdSync(List<String> schemaIdValues) {
    final values = schemaIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'schemaId', values);
  }

  Future<int> deleteAllBySchemaId(List<String> schemaIdValues) {
    final values = schemaIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'schemaId', values);
  }

  int deleteAllBySchemaIdSync(List<String> schemaIdValues) {
    final values = schemaIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'schemaId', values);
  }

  Future<Id> putBySchemaId(SchemaRec object) {
    return putByIndex(r'schemaId', object);
  }

  Id putBySchemaIdSync(SchemaRec object, {bool saveLinks = true}) {
    return putByIndexSync(r'schemaId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySchemaId(List<SchemaRec> objects) {
    return putAllByIndex(r'schemaId', objects);
  }

  List<Id> putAllBySchemaIdSync(List<SchemaRec> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'schemaId', objects, saveLinks: saveLinks);
  }
}

extension SchemaRecQueryWhereSort
    on QueryBuilder<SchemaRec, SchemaRec, QWhere> {
  QueryBuilder<SchemaRec, SchemaRec, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SchemaRecQueryWhere
    on QueryBuilder<SchemaRec, SchemaRec, QWhereClause> {
  QueryBuilder<SchemaRec, SchemaRec, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterWhereClause> idBetween(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterWhereClause> schemaIdEqualTo(
      String schemaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schemaId',
        value: [schemaId],
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterWhereClause> schemaIdNotEqualTo(
      String schemaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schemaId',
              lower: [],
              upper: [schemaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schemaId',
              lower: [schemaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schemaId',
              lower: [schemaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schemaId',
              lower: [],
              upper: [schemaId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SchemaRecQueryFilter
    on QueryBuilder<SchemaRec, SchemaRec, QFilterCondition> {
  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> contentEqualTo(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> contentGreaterThan(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> contentLessThan(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> contentBetween(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> contentStartsWith(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> contentEndsWith(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> contentContains(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> contentMatches(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> schemaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> schemaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> schemaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> schemaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> schemaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> schemaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> schemaIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> schemaIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schemaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition> schemaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaId',
        value: '',
      ));
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterFilterCondition>
      schemaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schemaId',
        value: '',
      ));
    });
  }
}

extension SchemaRecQueryObject
    on QueryBuilder<SchemaRec, SchemaRec, QFilterCondition> {}

extension SchemaRecQueryLinks
    on QueryBuilder<SchemaRec, SchemaRec, QFilterCondition> {}

extension SchemaRecQuerySortBy on QueryBuilder<SchemaRec, SchemaRec, QSortBy> {
  QueryBuilder<SchemaRec, SchemaRec, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterSortBy> sortBySchemaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaId', Sort.asc);
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterSortBy> sortBySchemaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaId', Sort.desc);
    });
  }
}

extension SchemaRecQuerySortThenBy
    on QueryBuilder<SchemaRec, SchemaRec, QSortThenBy> {
  QueryBuilder<SchemaRec, SchemaRec, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterSortBy> thenBySchemaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaId', Sort.asc);
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QAfterSortBy> thenBySchemaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaId', Sort.desc);
    });
  }
}

extension SchemaRecQueryWhereDistinct
    on QueryBuilder<SchemaRec, SchemaRec, QDistinct> {
  QueryBuilder<SchemaRec, SchemaRec, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchemaRec, SchemaRec, QDistinct> distinctBySchemaId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaId', caseSensitive: caseSensitive);
    });
  }
}

extension SchemaRecQueryProperty
    on QueryBuilder<SchemaRec, SchemaRec, QQueryProperty> {
  QueryBuilder<SchemaRec, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SchemaRec, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<SchemaRec, String, QQueryOperations> schemaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaId');
    });
  }
}
