package org.bigbluebutton.lib.video.models {
	import org.osflash.signals.Signal;
	
	public interface IVideoProfileManager {
		function get loaded():Boolean;
		function get loadedSignal():Signal;
		function parseProfilesXml(profileXML:XML):void;
		function parseConfigXml(configXML:XML):void;
		function get profiles():Array;
		function getVideoProfileById(id:String):VideoProfile;
		function getVideoProfileByStreamName(streamName:String):VideoProfile;
		function get defaultVideoProfile():VideoProfile;
		function get fallbackVideoProfile():VideoProfile;
		function getProfileWithLowerResolution():VideoProfile;
	}
}
