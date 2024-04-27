import "package:http/http.dart" as http;

class API{
  final baseUrl = "{API Endpoint}";

  Future<dynamic> processImage({img_path,prompt})async{
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/process-image'));
    request.fields.addAll({
      'prompt': prompt,
    });
    print("Request Sent awaiting response");
    
    request.files.add(await http.MultipartFile.fromPath('file', '$img_path'));

    try{
        http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        return [0, "Image generation Succesfull"];
      }
      else {
        print(response.reasonPhrase);
        return [1, "Error occurred: ${response.reasonPhrase}"];
      }
    }catch(e){
      return [2, "Please check you internet connection"];
    }
  }
}