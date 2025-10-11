import 'package:file_picker/file_picker.dart';

class ExcelImportService {
  static Future<List<int>?> pickAndReadExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: true,
    );
    
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        return file.bytes;
      }
    }
    
    return null;
  }
}