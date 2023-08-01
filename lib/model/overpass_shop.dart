import "package:latlong2/latlong.dart";

class OverPassShop {
  int id;
  LatLng latlng;
  String name;
  String? amenity;
  String? address;

  OverPassShop(
      {required this.id,
      required this.latlng,
      required this.name,
      this.amenity,
      this.address});

  factory OverPassShop.fromJson(Map<String, dynamic> jsonData) {
    int id = jsonData["id"];
    var latlng = LatLng(jsonData["lat"], jsonData["lon"]);
    String name = jsonData["tags"]["name"];
    String? amenity = jsonData["tags"]["amenity"];
    String? addrProvince = jsonData["tags"]["addr:province"];
    String? addrCity = jsonData["tags"]["addr:city"];
    String? addrNeighbourhood = jsonData["tags"]["addr:neighbourhood"];
    String? addrSuburb = jsonData["tags"]["addr:suburb"];

    // 店舗
    if (jsonData["tags"]["branch"] != null)
      name += " ${jsonData["tags"]["branch"]}";

    // 住所
    String? addr = (addrProvince ?? "") +
        (addrCity ?? "") +
        (addrSuburb ?? "") +
        (addrNeighbourhood ?? "");
    addr = addr != "" ? addr : null;

    return OverPassShop(
        id: id, latlng: latlng, amenity: amenity, name: name, address: addr);
  }
}
