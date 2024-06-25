import 'package:file_picker/file_picker.dart';

import 'package:kurban_app/src/services/share_video.dart';
import 'package:kurban_app/src/models/group.dart';
import 'package:kurban_app/src/models/person.dart';

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
