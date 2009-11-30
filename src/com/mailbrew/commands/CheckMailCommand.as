package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.data.AccountTypes;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.email.EmailEvent;
	import com.mailbrew.email.IEmailService;
	import com.mailbrew.email.gmail.Gmail;
	import com.mailbrew.email.imap.IMAP;
	import com.mailbrew.model.ModelLocator;
	
	import mx.collections.ArrayCollection;
	
	public class CheckMailCommand implements ICommand
	{
		private var accountData:Array;
		private var currentAccount:Object;
		private var unseenTotal:Number;
		private var ml:ModelLocator;
		
		public function execute(e:CairngormEvent):void
		{
			this.ml = ModelLocator.getInstance();
			if (this.ml.checkEmailLock) return;
			this.ml.checkEmailLock = true;
			var db:Database = this.ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				accountData = e.data;
				unseenTotal = 0;
				checkEmail();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.getAccounts(responder);
		}
		
		public function checkEmail():void
		{
			if (this.accountData == null || this.accountData.length == 0)
			{
				this.ml.checkEmailLock = false;
				return;
			}
			this.currentAccount = this.accountData.pop();
			var emailService:IEmailService;
			if (this.currentAccount.account_type == AccountTypes.IMAP)
			{
				emailService = new IMAP(this.currentAccount.username,
										this.currentAccount.password,
										this.currentAccount.imap_server,
										Number(this.currentAccount.port_number),
										Boolean(this.currentAccount.secure));
			}
			else if (this.currentAccount.account_type == AccountTypes.GMAIL)
			{
				emailService = new Gmail(this.currentAccount.username, this.currentAccount.password);
			}
			
			emailService.addEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
			emailService.addEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
			emailService.addEventListener(EmailEvent.UNSEEN_EMAILS, onUnseenEmails);
			
			//emailService.getUnseenEmailHeaders();
		}
		
		private function onAuthenticationFailed(e:EmailEvent):void
		{
			var emailService:IEmailService = e.target as IEmailService;
			emailService.removeEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
		}
		
		private function onConnectionFailed(e:EmailEvent):void
		{
			var emailService:IEmailService = e.target as IEmailService;
			emailService.removeEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
		}
		
		private function onUnseenEmails(e:EmailEvent):void
		{
			var emailService:IEmailService = e.target as IEmailService;
			emailService.removeEventListener(EmailEvent.UNSEEN_EMAILS, onUnseenEmails);
		}
	}
}