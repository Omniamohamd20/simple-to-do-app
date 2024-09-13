class CategoryData {
  int? id;
  String? name;

  // constructor
  CategoryData.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    name = data["name"];

  }
  Map<String, dynamic> toJson() {
    return {"id": id, "name": name};
  }
}
