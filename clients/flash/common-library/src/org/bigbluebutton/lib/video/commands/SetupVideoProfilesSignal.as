package org.bigbluebutton.lib.video.commands {
	import org.osflash.signals.Signal;
	
	public class SetupVideoProfilesSignal extends Signal {
		/**
		 * @1 url to retrive profiles.xml
		 */
		public function SetupVideoProfilesSignal() {
			super(String);
		}
	}
}
