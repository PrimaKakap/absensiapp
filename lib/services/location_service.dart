import 'package:geolocator/geolocator.dart';

class LocationService {
  //ambil dan validasi posisi GPS terbaru
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan GPS/Lokasi pada hp tidak aktif. Mohon aktifkan GPS anjing.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); {
        throw Exception('izin akses lokasi ditolak.');
      }
    }
if (permission == LocationPermission.deniedForever){
  throw Exception('izin akses lokasi ditolak secara permenent. Mohon izinkan lewat Pengaturan HP.');
}
//mengambil posisi
Position position = await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.high,
  ),
);
//anti fraud
if (position.isMocked){
  throw Exception('sistem mendeteksi pengunaan Fake GPS / Lokasi Palsu!');
}
return position;
  }
}