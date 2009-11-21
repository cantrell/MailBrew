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
		}
	}
}
