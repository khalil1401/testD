public with sharing class EmailController {
	public static Map<String, String> getMailTemplate(
		Id targetObjectId,
		String subject,
		String body
	) {
		Map<String, String> mailTemplate = new Map<String, String>();

		mailTemplate.put('targetObjectId', targetObjectId);
		mailTemplate.put('subject', subject);
		mailTemplate.put('body', body);

		return mailTemplate;
	}

	private static List<Messaging.SingleEmailMessage> buildEmailMessages(List<Map<String, String>> mailsTemplates) {
		List<Messaging.SingleEmailMessage> singleMessages = new List<Messaging.SingleEmailMessage>();

		for (Object mailTemplate : mailsTemplates) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			Map<String, String> template = (Map<String, String>)mailTemplate;
			// mail.setTemplateId(emailTemplate.Id);
			mail.setSaveAsActivity(false);
			mail.setTargetObjectId(template.get('targetObjectId'));
			mail.setSubject(String.valueOf(template.get('subject')));
			mail.setHtmlBody(template.get('body'));
			// mail.setSenderDisplayName(String.valueOf(mailTemplate.get('subject')));

			singleMessages.add(mail);
		}

		return singleMessages;
	}

	private static ServerResponse emailsResult(List<Messaging.SingleEmailMessage> mails) {
		List<Messaging.SendEmailResult> mailsResults = Messaging.sendEmail(mails);
		ServerResponse response = new ServerResponse();

		for (Messaging.SendEmailResult mailResult : mailsResults) {
			if (mailResult.success) {
				System.debug('The email was sent successfully.');
			} else {
				for (Messaging.SendEmailError error : mailResult.getErrors()) {
					response.addError(String.valueOf(error.getStatusCode()), error.getMessage());
					System.debug('The email failed to send: ' + error.getMessage());
				}
			}
		}

		response.state = response.hasErrors() ? 'SUCCESS' : 'ERROR';

		return response;
	}

	public static ServerResponse sendMail(List<Map<String, String>> mailsTemplates) {
		List<Messaging.SingleEmailMessage> messages = buildEmailMessages(mailsTemplates);
		ServerResponse response = emailsResult(messages);

		return response;
	}
}