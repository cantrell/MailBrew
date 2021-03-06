package com.mailbrew.controller
{
	import com.adobe.cairngorm.control.FrontController;
	
	public class Controller
		extends FrontController
	{

		import com.mailbrew.events.*;
		import com.mailbrew.commands.*;

		public function Controller()
		{
			this.addCommands();
		}
		
		private function addCommands():void
		{
			this.addCommand(InitEvent.INIT_EVENT, InitCommand);
			this.addCommand(SaveAccountEvent.SAVE_ACCOUNT_EVENT, SaveAccountCommand);
			this.addCommand(DeleteAccountEvent.DELETE_ACCOUNT_EVENT, DeleteAccountCommand);
			this.addCommand(PopulateAccountListEvent.POPULATE_ACCOUNT_LIST_EVENT, PopulateAccountListCommand);
			this.addCommand(PopulateAccountInfoEvent.POPULATE_ACCOUNT_INFO_EVENT, PopulateAccountInfoCommand);
			this.addCommand(CheckMailEvent.CHECK_MAIL_EVENT, CheckMailCommand);
			this.addCommand(UpdateAppIconEvent.UPDATE_APP_ICON_EVENT, UpdateAppIconCommand);
			this.addCommand(AppExitEvent.APP_EXIT_EVENT, AppExitCommand);
			this.addCommand(SavePreferencesEvent.SAVE_PREFERENCES_EVENT, SavePreferencesCommand);
			this.addCommand(VerifyAccountEvent.VERIFY_ACCOUNT_EVENT, VerifyAccountCommand);
			this.addCommand(ReorderAccountsEvent.REORDER_ACCOUNTS_EVENT, ReorderAccountsCommand);
			this.addCommand(ResetEvent.RESET_EVENT, ResetCommand);
		}
	}
}
