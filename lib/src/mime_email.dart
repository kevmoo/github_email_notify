library api.mime_email;

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
    String issueBody) {
  var subject =
      "[+${labelName}]: ${issueTitle} (${repositoryName}#${issueNumber})";

  var body = '''
 User: ${senderUser} - ${senderUrl}
Label: ${labelName}

${issueUrl}
${issueTitle}

${issueBody}
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

  emailContent.write('''Content-Type: text/plain; charset=UTF-8

$body''');

  return emailContent.toString();
}
