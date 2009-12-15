package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.data.AccountTypes;
	import com.mailbrew.email.EmailEvent;
	import com.mailbrew.email.IEmailService;
	import com.mailbrew.email.google.Gmail;
	import com.mailbrew.email.google.Wave;
	import com.mailbrew.email.imap.IMAP;
	import com.mailbrew.events.VerifyAccountEvent;
	import com.mailbrew.model.ModelLocator;
	import com.mailbrew.util.EmailServiceFactory;
	import com.mailbrew.util.StatusBarManager;
	
	import mx.controls.Alert;
	
	public class VerifyAccountCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var vae:VerifyAccountEvent = e as VerifyAccountEvent;
			StatusBarManager.showMessage("Verifying acount " + vae.accountName, true);
			var emailService:IEmailService = EmailServiceFactory.getEmailService(vae.accountType, vae.username, vae.password, vae.server, vae.portNumber, vae.secure);
			emailService.addEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
			emailService.addEventListener(EmailEvent.AUTHENTICATION_SUCCEEDED, onAuthenticationSucceeded);
			emailService.addEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
			emailService.addEventListener(EmailEvent.PROTOCOL_ERROR, onProtocolError);
			emailService.testAccount();
		}
		
		private function onAuthenticationFailed(e:EmailEvent):void
		{
			StatusBarManager.clearMessage();
			var emailService:IEmailService = e.target as IEmailService;
			emailService.removeEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
			Alert.show("Unable to log in. Please check your username and password, then try again.",
					   "Login Failed",
					   Alert.OK,
					   null, null,
					   ModelLocator.getInstance().faceCryingIconClass);
		}

		private function onAuthenticationSucceeded(e:EmailEvent):void
		{
			StatusBarManager.clearMessage();
			var emailService:IEmailService = e.target as IEmailService;
			emailService.removeEventListener(EmailEvent.AUTHENTICATION_SUCCEEDED, onAuthenticationSucceeded);
			Alert.show("Login successful! Everything appears to be in order!",
					   "Login Successful",
					   Alert.OK,
					   null, null,
					   ModelLocator.getInstance().faceSmileIconClass);
		}
		
		private function onConnectionFailed(e:EmailEvent):void
		{
			StatusBarManager.clearMessage();
			var emailService:IEmailService = e.target as IEmailService;
			emailService.removeEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
			Alert.show("Unable to connect. Please check your network settings and try again.",
					   "Connection Failure",
					   Alert.OK,
					   null, null,
					   ModelLocator.getInstance().faceCryingIconClass);
		}
		
		private function onProtocolError(e:EmailEvent):void
		{
			StatusBarManager.clearMessage();
			var emailService:IEmailService = e.target as IEmailService;
			emailService.removeEventListener(EmailEvent.PROTOCOL_ERROR, onProtocolError);
			Alert.show("Protocol error, which means you might have found a bug. Could you email this error to christian.cantrell@gmail.com? " + e.data,
					   "Protocol Error",
					   Alert.OK,
					   null, null,
					   ModelLocator.getInstance().faceCryingIconClass);
		}
	}
}