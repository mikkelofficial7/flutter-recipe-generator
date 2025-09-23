class GeminiData {
  static const String model = "gemini-2.0-flash";
  static const String url =
      "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent";
  static const String apikey = "AIzaSyAHBhEhi8gR5V7Dp7yiLtDanxF0BZW_0Ks";
  static const String prompt =
      "Generate sebuah resep masakan, cost bahan baku (estimasi dalam Rp), dan 1 url gambar ilustrasi hasil olahan terletak diatas bahan-bahan berdasarkan gambar-gambar sisa bahan baku berikut dengan tambahan bahan baku (jika ada) seminim mungkin tidak jauh dari bahan baku berikut. Url gambar di replace dengan format replace url dengan ![ilustrasi](https://xxxxx.com)";
}
