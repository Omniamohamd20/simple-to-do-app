class Task {
  int? id;
  String? name;
  String? content;
  bool? isDone;
  String? image;
  int? categoryId;
  String? categoryName;
  String? categoryDesc;
// map to model
  Task.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    name = data["name"];
    content = data["content"];
    isDone = data["isDone"] == 1 ? true : false;
    image = data["image"];
    categoryId = data["categoryId"];
    categoryName = data["categoryName"];
    categoryDesc = data["categoryDesc"];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "content": content,
      "isDone": isDone,
      "image": image,
      "categoryId": categoryId,
    };
  }
}
