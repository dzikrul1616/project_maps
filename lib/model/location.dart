class TampilContent {
  String? idContent;
  String? image;
  String? place;
  String? latitude;
  String? longtitude;
  String? description;
  String? dateContent;
  String? idUsers;
  String? username;

  TampilContent(
      this.idContent,
      this.image,
      this.place,
      this.latitude,
      this.longtitude,
      this.description,
      this.dateContent,
      this.idUsers,
      this.username);

  TampilContent.fromJson(Map<String, dynamic> json) {
    idContent = json['id_content'];
    image = json['image'];
    place = json['place'];
    latitude = json['latitude'];
    longtitude = json['longtitude'];
    description = json['description'];
    dateContent = json['date_content'];
    idUsers = json['id_users'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_content'] = this.idContent;
    data['image'] = this.image;
    data['place'] = this.place;
    data['latitude'] = this.latitude;
    data['longtitude'] = this.longtitude;
    data['description'] = this.description;
    data['date_content'] = this.dateContent;
    data['id_users'] = this.idUsers;
    data['username'] = this.username;
    return data;
  }
}
