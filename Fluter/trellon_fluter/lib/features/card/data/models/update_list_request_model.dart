class UpdateListRequestModel {
  final String listUId;
  final int position;

  UpdateListRequestModel({required this.listUId, required this.position});

  Map<String, dynamic> toJson() {
    return {
      'listUId': listUId,
      'position': position,
    };
  }
}
