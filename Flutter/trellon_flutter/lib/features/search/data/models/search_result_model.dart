class SearchResultModel {
  final List<SearchBoardModel> boards;
  final List<SearchCardModel> cards;

  SearchResultModel({required this.boards, required this.cards});

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      boards: (json['boards'] as List?)
              ?.map((e) => SearchBoardModel.fromJson(e))
              .toList() ??
          [],
      cards: (json['cards'] as List?)
              ?.map((e) => SearchCardModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SearchBoardModel {
  final String boardUId;
  final String boardName;
  final String? backgroundUrl;

  SearchBoardModel({
    required this.boardUId,
    required this.boardName,
    this.backgroundUrl,
  });

  factory SearchBoardModel.fromJson(Map<String, dynamic> json) {
    return SearchBoardModel(
      boardUId: json['boardUId'] ?? '',
      boardName: json['boardName'] ?? '',
      backgroundUrl: json['backgroundUrl'],
    );
  }
}

class SearchCardModel {
  final String cardUId;
  final String title;
  final String? boardName;
  final String? boardUId;

  SearchCardModel({
    required this.cardUId,
    required this.title,
    this.boardName,
    this.boardUId,
  });

  factory SearchCardModel.fromJson(Map<String, dynamic> json) {
    return SearchCardModel(
      cardUId: json['cardUId'] ?? '',
      title: json['title'] ?? '',
      boardName: json['boardName'],
      boardUId: json['boardUId'],
    );
  }
}
