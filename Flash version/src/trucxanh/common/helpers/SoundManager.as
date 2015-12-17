package trucxanh.common.helpers {
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Trung đẹp trai
	 */
	public class SoundManager extends Object {
		
		public static var channelArray: Array = [];
		public static var soundArray: Array = [];
		public static var isLoopArray: Array = [];
		private static var _soundOn: Boolean = true;
		private static var _volume: Number = 1;
		
		public function SoundManager() {
			
		}
		
		public static function playUrl(url: String, isLoop: Boolean = false): void {
			SoundManager.playSound(new Sound(new URLRequest(url)), isLoop);
		}
		
		public static function playSound(sound: Sound, isLoop: Boolean = false): void {
			var isExist: Boolean = false;
			for (var i: int = 0; i < soundArray.length; i++) {
				if (sound == soundArray[i]) {
					isExist = true;
					break;
				}
			}
			
			if (!isExist) {
				var soundChannel: SoundChannel = sound.play();
				soundChannel.soundTransform = new SoundTransform((soundOn) ? 1 : 0);
				soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
				
				channelArray.push(soundChannel);
				soundArray.push(sound);
				isLoopArray.push(isLoop);
			}
		}
		
		private static function soundCompleteHandler(event: Event): void {
			var soundChannel: SoundChannel = event.currentTarget as SoundChannel;
			var index: int = channelArray.indexOf(soundChannel);
			if (isLoopArray[index]) {
				channelArray[index] = soundArray[index].play();
				channelArray[index].soundTransform = new SoundTransform((soundOn) ? 1 : 0);
				channelArray[index].addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
			}
			else {
				channelArray.splice(index, 1);
				soundArray.splice(index, 1);
				isLoopArray.splice(index, 1);
			}
		}
		
		public static function stopSound(sound: Sound): void {
			for (var i: int = 0; i < soundArray.length; i++) {
				if (sound == soundArray[i]) {
					channelArray[i].stop();
					isLoopArray[i] = false;
					channelArray[i].dispatchEvent(new Event(Event.SOUND_COMPLETE));
				}
			}
		}
		
		public static function stopAllSound(): void {
			for (var i: int = 0; i < soundArray.length; i++) {
				channelArray[i].stop();
				isLoopArray[i] = false;				
			}
		}
		
		static public function get soundOn(): Boolean { return _soundOn; }
		
		static public function set soundOn(value: Boolean): void {
			_soundOn = value;
			for (var i: int = 0; i < channelArray.length; i++) {
				channelArray[i].soundTransform = new SoundTransform((soundOn) ? 1 : 0);
			}
		}
		
		static public function get volume(): Number { return _volume; }
		
		static public function set volume(value: Number): void {
			_volume = value;
			for (var i: int = 0; i < channelArray.length; i++) {
				channelArray[i].soundTransform = new SoundTransform(value);
			}
		}
	}

}