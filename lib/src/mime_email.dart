library api.mime_email;

import 'package:markdown/markdown.dart';

String createLabelEmailContent(
    String senderName,
    String senderEmail,
    Iterable<String> subscribedEmails,
    String labelName,
    String repositoryName,
    String senderUser,
    Uri senderUrl,
    int issueNumber,
    String issueTitle,
    Uri issueUrl,
    String issueBody,
    String issueReporterUsername,
    Uri issueReporterUri) {
  var subject =
      "[+${labelName}]: ${issueTitle} (${repositoryName}#${issueNumber})";

  var body = '''
<p><strong><a href="${issueUrl}">${issueTitle}</a> (${repositoryName}#${issueNumber})</strong></p>
<p>Reported by <a href="${issueReporterUri}">${issueReporterUsername}</a></p>
<p>Labeled <strong>${labelName}</strong> by <a href="${senderUrl}">${senderUser}</a></p>

<hr>
${markdownToHtml(issueBody)}
''';

  return _createMimeContent(senderName, senderEmail, subject, body,
      bccEmails: subscribedEmails);
}

String _createMimeContent(
    String senderName, String senderEmail, String subject, String body,
    {Iterable<String> toEmails, Iterable<String> bccEmails}) {
  var fromLine = '$senderName <$senderEmail>';

  if (body == null) {
    body = '';
  }

  var emailContent = new StringBuffer()
    ..writeln('mime-version: 1.0')
    ..writeln('Subject: $subject')
    ..writeln('From: $fromLine');

  if (toEmails != null && toEmails.isNotEmpty) {
    emailContent.writeln('To: ${toEmails.join(',')}');
  }

  if (bccEmails != null && bccEmails.isNotEmpty) {
    emailContent.writeln('Bcc: ${bccEmails.join(', ')}');
  }

  emailContent.write('''Content-Type: text/html; charset=UTF-8

$body''');

  return emailContent.toString();
}
