import 'package:file_picker/file_picker.dart';
import 'package:kurban_app/ShareVideo.dart';
import 'package:kurban_app/models.dart';

void pickAndShareVideo(Group group) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

  if (result != null) {
    String videoPath = result.files.single.path!;

    for (var member in group.members) {
      if (member is StandalonePerson) {
        shareVideoViaWhatsApp(member.phoneNumber, videoPath);
      }
    }
  }
}
