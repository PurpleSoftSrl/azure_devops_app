import 'dart:convert';

class GetFileDiffResponse {
  factory GetFileDiffResponse.fromRawJson(String str) =>
      GetFileDiffResponse.fromJson(json.decode(str) as Map<String, dynamic>);

  factory GetFileDiffResponse.fromJson(Map<String, dynamic> json) => GetFileDiffResponse(
        data: DataProviders.fromJson(json['dataProviders'] as Map<String, dynamic>),
      );

  GetFileDiffResponse({
    required this.data,
  });

  final DataProviders data;
}

class DataProviders {
  factory DataProviders.fromRawJson(String str) => DataProviders.fromJson(json.decode(str) as Map<String, dynamic>);

  factory DataProviders.fromJson(Map<String, dynamic> json) => DataProviders(
        diff: Diff.fromJson(
          json['ms.vss-code-web.file-diff-data-provider'] as Map<String, dynamic>,
        ),
      );
  DataProviders({
    required this.diff,
  });

  final Diff diff;
}

class Diff {
  factory Diff.fromRawJson(String str) => Diff.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Diff.fromJson(Map<String, dynamic> json) => Diff(
        originalFile: json['originalFile'] == null
            ? null
            : ModifiedFileClass.fromJson(json['originalFile'] as Map<String, dynamic>),
        modifiedFile: json['modifiedFile'] == null
            ? null
            : ModifiedFileClass.fromJson(json['modifiedFile'] as Map<String, dynamic>),
        blocks:
            List<Block>.from((json['blocks'] as List<dynamic>).map((l) => Block.fromJson(l as Map<String, dynamic>))),
        lineCharBlocks: List<LineCharBlock>.from(
          (json['lineCharBlocks'] as List<dynamic>?)?.map((l) => LineCharBlock.fromJson(l as Map<String, dynamic>)) ??
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

  final ModifiedFileClass? originalFile;
  final ModifiedFileClass? modifiedFile;
  final List<Block> blocks;
  final List<LineCharBlock> lineCharBlocks;
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

class LineCharBlock {
  factory LineCharBlock.fromRawJson(String str) => LineCharBlock.fromJson(json.decode(str) as Map<String, dynamic>);

  factory LineCharBlock.fromJson(Map<String, dynamic> json) => LineCharBlock(
        lineChange: Block.fromJson(json['lineChange'] as Map<String, dynamic>),
        charChange: json['charChange'] == null
            ? []
            : List<CharChange>.from(
                (json['charChange'] as List<dynamic>).map((c) => CharChange.fromJson(c as Map<String, dynamic>)),
              ),
      );

  LineCharBlock({
    required this.lineChange,
    this.charChange,
  });

  final Block lineChange;
  final List<CharChange>? charChange;
}

class CharChange {
  factory CharChange.fromRawJson(String str) => CharChange.fromJson(json.decode(str) as Map<String, dynamic>);

  factory CharChange.fromJson(Map<String, dynamic> json) => CharChange(
        changeType: json['changeType'] as int,
        oLine: json['oLine'] as int,
        oLinesCount: json['oLinesCount'] as int,
        mLine: json['mLine'] as int,
        mLinesCount: json['mLinesCount'] as int,
      );

  CharChange({
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

class ModifiedFileClass {
  factory ModifiedFileClass.fromRawJson(String str) =>
      ModifiedFileClass.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ModifiedFileClass.fromJson(Map<String, dynamic> json) => ModifiedFileClass(
        objectId: ObjectId.fromJson(json['objectId'] as Map<String, dynamic>),
        gitObjectType: json['gitObjectType'] as int,
        commitId: json['commitId'] as String?,
        serverItem: json['serverItem'] as String,
        version: json['version'] as String,
        contentMetadata: ContentMetadata.fromJson(json['contentMetadata'] as Map<String, dynamic>),
        versionDescription: json['versionDescription'] as String,
      );

  ModifiedFileClass({
    required this.objectId,
    required this.gitObjectType,
    this.commitId,
    required this.serverItem,
    required this.version,
    required this.contentMetadata,
    required this.versionDescription,
  });

  final ObjectId objectId;
  final int gitObjectType;
  final String? commitId;
  final String serverItem;
  final String version;
  final ContentMetadata contentMetadata;
  final String versionDescription;
}

class ContentMetadata {
  factory ContentMetadata.fromRawJson(String str) => ContentMetadata.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ContentMetadata.fromJson(Map<String, dynamic> json) => ContentMetadata(
        encoding: json['encoding'] as int,
        contentType: json['contentType'] as String,
        fileName: json['fileName'] as String,
        extension: json['extension'] as String,
        vsLink: json['vsLink'] as String,
      );

  ContentMetadata({
    required this.encoding,
    required this.contentType,
    required this.fileName,
    required this.extension,
    required this.vsLink,
  });

  final int encoding;
  final String contentType;
  final String fileName;
  final String extension;
  final String vsLink;
}

class ObjectId {
  factory ObjectId.fromRawJson(String str) => ObjectId.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ObjectId.fromJson(Map<String, dynamic> json) => ObjectId(
        full: json['full'] as String,
        short: json['short'] as String,
      );

  ObjectId({
    required this.full,
    required this.short,
  });

  final String full;
  final String short;
}
