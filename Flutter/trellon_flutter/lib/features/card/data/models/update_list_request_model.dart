class UpdateListRequestModel {
  final String listUId;
  final String userUId;

  UpdateListRequestModel({required this.listUId, required this.userUId});

  Map<String, dynamic> toJson() {
    return {
      'listUId': listUId,
      'userUId': userUId,
    };
  }
}
