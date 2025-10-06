// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle_rec.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBundleRecCollection on Isar {
  IsarCollection<BundleRec> get bundleRecs => this.collection();
}

const BundleRecSchema = CollectionSchema(
  name: r'BundleRec',
  id: -7011060216900965474,
  properties: {
    r'bundleId': PropertySchema(
      id: 0,
      name: r'bundleId',
      type: IsarType.string,
    ),
    r'content': PropertySchema(
      id: 1,
      name: r'content',
      type: IsarType.string,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _bundleRecEstimateSize,
  serialize: _bundleRecSerialize,
  deserialize: _bundleRecDeserialize,
  deserializeProp: _bundleRecDeserializeProp,
  idName: r'id',
  indexes: {
    r'bundleId': IndexSchema(
      id: 4295377478569876265,
      name: r'bundleId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bundleId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bundleRecGetId,
  getLinks: _bundleRecGetLinks,
  attach: _bundleRecAttach,
  version: '3.1.0+1',
);

int _bundleRecEstimateSize(
  BundleRec object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bundleId.length * 3;
  bytesCount += 3 + object.content.length * 3;
  return bytesCount;
}

void _bundleRecSerialize(
  BundleRec object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bundleId);
  writer.writeString(offsets[1], object.content);
  writer.writeDateTime(offsets[2], object.lastUpdated);
}

BundleRec _bundleRecDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BundleRec();
  object.bundleId = reader.readString(offsets[0]);
  object.content = reader.readString(offsets[1]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[2]);
  return object;
}

P _bundleRecDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bundleRecGetId(BundleRec object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bundleRecGetLinks(BundleRec object) {
  return [];
}

void _bundleRecAttach(IsarCollection<dynamic> col, Id id, BundleRec object) {
  object.id = id;
}

extension BundleRecByIndex on IsarCollection<BundleRec> {
  Future<BundleRec?> getByBundleId(String bundleId) {
    return getByIndex(r'bundleId', [bundleId]);
  }

  BundleRec? getByBundleIdSync(String bundleId) {
    return getByIndexSync(r'bundleId', [bundleId]);
  }

  Future<bool> deleteByBundleId(String bundleId) {
    return deleteByIndex(r'bundleId', [bundleId]);
  }

  bool deleteByBundleIdSync(String bundleId) {
    return deleteByIndexSync(r'bundleId', [bundleId]);
  }

  Future<List<BundleRec?>> getAllByBundleId(List<String> bundleIdValues) {
    final values = bundleIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'bundleId', values);
  }

  List<BundleRec?> getAllByBundleIdSync(List<String> bundleIdValues) {
    final values = bundleIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'bundleId', values);
  }

  Future<int> deleteAllByBundleId(List<String> bundleIdValues) {
    final values = bundleIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'bundleId', values);
  }

  int deleteAllByBundleIdSync(List<String> bundleIdValues) {
    final values = bundleIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'bundleId', values);
  }

  Future<Id> putByBundleId(BundleRec object) {
    return putByIndex(r'bundleId', object);
  }

  Id putByBundleIdSync(BundleRec object, {bool saveLinks = true}) {
    return putByIndexSync(r'bundleId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBundleId(List<BundleRec> objects) {
    return putAllByIndex(r'bundleId', objects);
  }

  List<Id> putAllByBundleIdSync(List<BundleRec> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'bundleId', objects, saveLinks: saveLinks);
  }
}

extension BundleRecQueryWhereSort
    on QueryBuilder<BundleRec, BundleRec, QWhere> {
  QueryBuilder<BundleRec, BundleRec, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BundleRecQueryWhere
    on QueryBuilder<BundleRec, BundleRec, QWhereClause> {
  QueryBuilder<BundleRec, BundleRec, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<BundleRec, BundleRec, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterWhereClause> idBetween(
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

  QueryBuilder<BundleRec, BundleRec, QAfterWhereClause> bundleIdEqualTo(
      String bundleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bundleId',
        value: [bundleId],
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterWhereClause> bundleIdNotEqualTo(
      String bundleId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bundleId',
              lower: [],
              upper: [bundleId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bundleId',
              lower: [bundleId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bundleId',
              lower: [bundleId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bundleId',
              lower: [],
              upper: [bundleId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BundleRecQueryFilter
    on QueryBuilder<BundleRec, BundleRec, QFilterCondition> {
  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> bundleIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> bundleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> bundleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> bundleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bundleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> bundleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> bundleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> bundleIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bundleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> bundleIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bundleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> bundleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bundleId',
        value: '',
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition>
      bundleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bundleId',
        value: '',
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> contentEqualTo(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> contentGreaterThan(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> contentLessThan(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> contentBetween(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> contentStartsWith(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> contentEndsWith(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> contentContains(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> contentMatches(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> lastUpdatedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterFilterCondition> lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BundleRecQueryObject
    on QueryBuilder<BundleRec, BundleRec, QFilterCondition> {}

extension BundleRecQueryLinks
    on QueryBuilder<BundleRec, BundleRec, QFilterCondition> {}

extension BundleRecQuerySortBy on QueryBuilder<BundleRec, BundleRec, QSortBy> {
  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> sortByBundleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bundleId', Sort.asc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> sortByBundleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bundleId', Sort.desc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension BundleRecQuerySortThenBy
    on QueryBuilder<BundleRec, BundleRec, QSortThenBy> {
  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> thenByBundleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bundleId', Sort.asc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> thenByBundleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bundleId', Sort.desc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension BundleRecQueryWhereDistinct
    on QueryBuilder<BundleRec, BundleRec, QDistinct> {
  QueryBuilder<BundleRec, BundleRec, QDistinct> distinctByBundleId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bundleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BundleRec, BundleRec, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }
}

extension BundleRecQueryProperty
    on QueryBuilder<BundleRec, BundleRec, QQueryProperty> {
  QueryBuilder<BundleRec, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BundleRec, String, QQueryOperations> bundleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bundleId');
    });
  }

  QueryBuilder<BundleRec, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<BundleRec, DateTime, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }
}
