package org.bigbluebutton.web.video {
	import org.bigbluebutton.lib.video.commands.SetupVideoProfilesCommand;
	import org.bigbluebutton.lib.video.commands.SetupVideoProfilesSignal;
	import org.bigbluebutton.lib.video.models.IVideoProfileManager;
	import org.bigbluebutton.lib.video.models.VideoProfileManager;
	import org.bigbluebutton.web.video.views.VideoWindow;
	import org.bigbluebutton.web.video.views.VideoWindowMediator;
	
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IConfig;
	import robotlegs.bender.framework.api.IInjector;
	
	public class VideoConfig implements IConfig {
		
		[Inject]
		public var injector:IInjector;
		
		[Inject]
		public var mediatorMap:IMediatorMap;
		
		[Inject]
		public var signalCommandMap:ISignalCommandMap;
		
		public function configure():void {
			dependencies();
			mediators();
			signals();
		}
		
		/**
		 * Specifies all the dependencies for the feature
		 * that will be injected onto objects used by the
		 * application.
		 */
		private function dependencies():void {
			//injector.map(IChatMessageService).toSingleton(ChatMessageService);
			injector.map(IVideoProfileManager).toSingleton(VideoProfileManager);
		}
		
		/**
		 * Maps view mediators to views.
		 */
		private function mediators():void {
			mediatorMap.map(VideoWindow).toMediator(VideoWindowMediator);
		}
		
		/**
		 * Maps signals to commands using the signalCommandMap.
		 */
		private function signals():void {
			signalCommandMap.map(SetupVideoProfilesSignal).toCommand(SetupVideoProfilesCommand);
		}
	}
}
