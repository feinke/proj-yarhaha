class AmiiboPost {
  final String id;
  final String name;
  final String image;

  AmiiboPost({this.id, this.name, this.image});

  factory AmiiboPost.fromJson(Map<String, dynamic> json) {
    return AmiiboPost(
      id: json['head'] + json['tail'],
      name: json['name'],
      image: json['image'],
    );
  }
}
