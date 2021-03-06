package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.components.IconAlert;
	import com.mailbrew.email.EmailEvent;
	import com.mailbrew.email.IEmailService;
	import com.mailbrew.events.VerifyAccountEvent;
	import com.mailbrew.util.EmailServiceFactory;
	import com.mailbrew.util.StatusBarManager;
	
	public class VerifyAccountCommand
		implements ICommand
	{
		// Only want one of these to exist
		private static var emailService:IEmailService;
		
		public function execute(e:CairngormEvent):void
		{
			var vae:VerifyAccountEvent = e as VerifyAccountEvent;
			StatusBarManager.showMessage("Verifying acount " + vae.accountName, true);
			this.disposeEmailService();
			emailService = EmailServiceFactory.getEmailService(vae.accountType, vae.username, vae.password, vae.server, vae.portNumber, vae.secure);
			emailService.addEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
			emailService.addEventListener(EmailEvent.AUTHENTICATION_SUCCEEDED, onAuthenticationSucceeded);
			emailService.addEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
			emailService.addEventListener(EmailEvent.PROTOCOL_ERROR, onProtocolError);
			emailService.testAccount();
		}
		
		private function disposeEmailService():void
		{
			if (emailService != null)
			{
				emailService.removeEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
				emailService.removeEventListener(EmailEvent.AUTHENTICATION_SUCCEEDED, onAuthenticationSucceeded);
				emailService.removeEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
				emailService.removeEventListener(EmailEvent.PROTOCOL_ERROR, onProtocolError);
				emailService.dispose();
				emailService = null;
			}
		}

		private function onAuthenticationFailed(e:EmailEvent):void
		{
			StatusBarManager.clearMessage();
			var es:IEmailService = e.target as IEmailService;
			es.removeEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
			IconAlert.showFailure("Login Failed", "Unable to log in. Please check your username and password, then try again.");
			this.disposeEmailService();
		}

		private function onAuthenticationSucceeded(e:EmailEvent):void
		{
			StatusBarManager.clearMessage();
			var es:IEmailService = e.target as IEmailService;
			es.removeEventListener(EmailEvent.AUTHENTICATION_SUCCEEDED, onAuthenticationSucceeded);
			IconAlert.showInformation("Login Successful", "Everything appears to be in order!");
			this.disposeEmailService();
		}
		
		private function onConnectionFailed(e:EmailEvent):void
		{
			StatusBarManager.clearMessage();
			var es:IEmailService = e.target as IEmailService;
			es.removeEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
			IconAlert.showFailure("Connection Failure", "Unable to connect. Please check your network settings and try again.");
			this.disposeEmailService();
		}
		
		private function onProtocolError(e:EmailEvent):void
		{
			StatusBarManager.clearMessage();
			var es:IEmailService = e.target as IEmailService;
			es.removeEventListener(EmailEvent.PROTOCOL_ERROR, onProtocolError);
			IconAlert.showFailure("Protocol Error", "You might have found a bug. Could you email this error to christian.cantrell@gmail.com? [" + e.data + "]");
			this.disposeEmailService();
		}
	}
}