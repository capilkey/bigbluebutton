package org.bigbluebutton.lib.video.commands {
	import org.bigbluebutton.lib.common.utils.URLParser;
	import org.bigbluebutton.lib.main.models.IUserSession;
	import org.bigbluebutton.lib.video.models.IVideoProfileManager;
	import org.bigbluebutton.lib.video.services.VideoProfilesService;
	
	import robotlegs.bender.bundles.mvcs.Command;
	
	public class SetupVideoProfilesCommand extends Command {
		
		[Inject]
		public var userSession:IUserSession;
		
		[Inject]
		public var videoProfileManager:IVideoProfileManager;
		
		[Inject]
		public var url:String;
		
		public override function execute():void {
			var videoProfilesService:VideoProfilesService = new VideoProfilesService();
			videoProfilesService.successSignal.add(profilesSuccess);
			videoProfilesService.failureSignal.add(profilesFailure);
			videoProfilesService.getProfiles(getServerUrl(url));
		}
		
		protected function profilesSuccess(xml:XML):void {
			videoProfileManager.parseProfilesXml(xml);
		}
		
		protected function profilesFailure(reason:String):void {
			trace("Video profiles failed to retrieve, falling back to config.xml");
			videoProfileManager.parseConfigXml(userSession.config.getConfigFor("VideoconfModule"));
		}
		
		protected function getServerUrl(url:String):String {
			var parser:URLParser = new URLParser(url);
			return parser.protocol + "://" + parser.host + ":" + parser.port;
		}
	}
}
