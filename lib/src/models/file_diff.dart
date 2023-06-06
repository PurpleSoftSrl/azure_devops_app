import 'dart:convert';

import 'package:http/http.dart';

class GetFileDiffResponse {
  factory GetFileDiffResponse.fromJson(Map<String, dynamic> json) => GetFileDiffResponse(
        data: _DataProviders.fromJson(json['dataProviders'] as Map<String, dynamic>),
      );

  GetFileDiffResponse({required this.data});

  static Diff fromResponse(Response res) =>
      GetFileDiffResponse.fromJson(json.decode(res.body) as Map<String, dynamic>).data.diff;

  final _DataProviders data;
}

class _DataProviders {
  factory _DataProviders.fromJson(Map<String, dynamic> json) => _DataProviders(
        diff: Diff.fromJson(
          json['ms.vss-code-web.file-diff-data-provider'] as Map<String, dynamic>,
        ),
      );
  _DataProviders({
    required this.diff,
  });

  final Diff diff;
}

class Diff {
  factory Diff.fromRawJson(String str) => Diff.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Diff.fromJson(Map<String, dynamic> json) => Diff(
        originalFile: json['originalFile'] == null
            ? null
            : _ModifiedFileClass.fromJson(json['originalFile'] as Map<String, dynamic>),
        modifiedFile: json['modifiedFile'] == null
            ? null
            : _ModifiedFileClass.fromJson(json['modifiedFile'] as Map<String, dynamic>),
        blocks:
            List<Block>.from((json['blocks'] as List<dynamic>).map((l) => Block.fromJson(l as Map<String, dynamic>))),
        lineCharBlocks: List<_LineCharBlock>.from(
          (json['lineCharBlocks'] as List<dynamic>?)?.map((l) => _LineCharBlock.fromJson(l as Map<String, dynamic>)) ??
              [],
        ),
        binaryContent: json['binaryContent'] as bool? ?? false,
        imageComparison: json['imageComparison'] as bool? ?? false,
      );

  Diff({
    required this.originalFile,
    required this.modifiedFile,
    required this.blocks,
    required this.lineCharBlocks,
    this.binaryContent = false,
    this.imageComparison = false,
  });

  final _ModifiedFileClass? originalFile;
  final _ModifiedFileClass? modifiedFile;
  final List<Block> blocks;
  final List<_LineCharBlock> lineCharBlocks;
  final bool binaryContent;
  final bool imageComparison;
}

class Block {
  factory Block.fromRawJson(String str) => Block.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        changeType: json['changeType'] as int,
        oLine: json['oLine'] as int?,
        oLinesCount: json['oLinesCount'] as int?,
        mLine: json['mLine'] as int,
        mLinesCount: json['mLinesCount'] as int,
        oLines: List<String>.from((json['oLines'] as List<dynamic>? ?? []).map((x) => x)),
        mLines: List<String>.from((json['mLines'] as List<dynamic>? ?? []).map((x) => x)),
        truncatedBefore: json['truncatedBefore'] as bool?,
        truncatedAfter: json['truncatedAfter'] as bool?,
      );

  Block({
    required this.changeType,
    required this.oLine,
    required this.oLinesCount,
    required this.mLine,
    required this.mLinesCount,
    required this.oLines,
    required this.mLines,
    this.truncatedBefore,
    this.truncatedAfter,
  });

  final int changeType;
  final int? oLine;
  final int? oLinesCount;
  final int mLine;
  final int mLinesCount;
  final List<String> oLines;
  final List<String> mLines;
  final bool? truncatedBefore;
  final bool? truncatedAfter;
}

class _LineCharBlock {
  factory _LineCharBlock.fromJson(Map<String, dynamic> json) => _LineCharBlock(
        lineChange: Block.fromJson(json['lineChange'] as Map<String, dynamic>),
        charChange: json['charChange'] == null
            ? []
            : List<_CharChange>.from(
                (json['charChange'] as List<dynamic>).map((c) => _CharChange.fromJson(c as Map<String, dynamic>)),
              ),
      );

  _LineCharBlock({
    required this.lineChange,
    this.charChange,
  });

  final Block lineChange;
  final List<_CharChange>? charChange;
}

class _CharChange {
  factory _CharChange.fromJson(Map<String, dynamic> json) => _CharChange(
        changeType: json['changeType'] as int,
        oLine: json['oLine'] as int,
        oLinesCount: json['oLinesCount'] as int,
        mLine: json['mLine'] as int,
        mLinesCount: json['mLinesCount'] as int,
      );

  _CharChange({
    required this.changeType,
    required this.oLine,
    required this.oLinesCount,
    required this.mLine,
    required this.mLinesCount,
  });

  final int changeType;
  final int oLine;
  final int oLinesCount;
  final int mLine;
  final int mLinesCount;
}

class _ModifiedFileClass {
  factory _ModifiedFileClass.fromJson(Map<String, dynamic> json) => _ModifiedFileClass(
        objectId: _ObjectId.fromJson(json['objectId'] as Map<String, dynamic>),
        gitObjectType: json['gitObjectType'] as int,
        commitId: json['commitId'] as String?,
        serverItem: json['serverItem'] as String,
        version: json['version'] as String,
        contentMetadata: _ContentMetadata.fromJson(json['contentMetadata'] as Map<String, dynamic>),
        versionDescription: json['versionDescription'] as String,
      );

  _ModifiedFileClass({
    required this.objectId,
    required this.gitObjectType,
    this.commitId,
    required this.serverItem,
    required this.version,
    required this.contentMetadata,
    required this.versionDescription,
  });

  final _ObjectId objectId;
  final int gitObjectType;
  final String? commitId;
  final String serverItem;
  final String version;
  final _ContentMetadata contentMetadata;
  final String versionDescription;
}

class _ContentMetadata {
  factory _ContentMetadata.fromJson(Map<String, dynamic> json) => _ContentMetadata(
        encoding: json['encoding'] as int,
        contentType: json['contentType'] as String,
        fileName: json['fileName'] as String,
        extension: json['extension'] as String,
      );

  _ContentMetadata({
    required this.encoding,
    required this.contentType,
    required this.fileName,
    required this.extension,
  });

  final int encoding;
  final String contentType;
  final String fileName;
  final String extension;
}

class _ObjectId {
  factory _ObjectId.fromJson(Map<String, dynamic> json) => _ObjectId(
        full: json['full'] as String,
        short: json['short'] as String,
      );

  _ObjectId({
    required this.full,
    required this.short,
  });

  final String full;
  final String short;
}
