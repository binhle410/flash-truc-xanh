package trucxanh.common.helpers {
	import com.ritz.framework.logging.Logger;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Trung Đẹp Trai
	 */
	public class ImageLoader extends Sprite {
		private static var loadedAssets: Object = {};
		
		public static const ALIGN_NORMAL: String = "normal";
		public static const ALIGN_CENTER: String = "center";
		
		private var url: String = "";
		private var align: String = "";
		private var bitmapData: BitmapData;		
		private var loader:Loader;
		
		private var timeout: Timer;
		
		public function ImageLoader(url: String, align: String = ALIGN_NORMAL) {
			if (!url)	return;
			this.align = align;
			this.url = url;
			
			timeout = new Timer(2000, 1);
			timeout.addEventListener(TimerEvent.TIMER_COMPLETE, timeoutHandler);
			
			this.startLoading();
		}
		
		private function timeoutHandler(e:TimerEvent):void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.unload();
			this.startLoading();
		}
		
		private function startLoading(): void {
			//timeout.reset();
			//timeout.start();
			
			bitmapData = ImageLoader.loadedAssets[this.url];
			if (bitmapData)	processBitmapData(true);
			else	loadImage(url);	
			//loadImage(url);	
		}
		
		private function loadImage(url: String): void {
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			loader.load(new URLRequest(url));
		}
		
		private function loaderCompleteHandler(e:Event):void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
			bitmapData = Bitmap(loader.content).bitmapData;
			processBitmapData();
		}
		
		private function processBitmapData(isLoaded: Boolean = false): void {
			var bitmap: Bitmap = new Bitmap(bitmapData, "auto", true);
			switch (align) {
				case ImageLoader.ALIGN_CENTER:
					bitmap.x = - bitmap.width / 2;
					bitmap.y = - bitmap.height / 2;
					break;
				default:
					bitmap.x = 0;
					bitmap.y = 0;
					break;
			}
			this.addChild(bitmap);
			
			ImageLoader.loadedAssets[this.url] = bitmapData;
			//timeout.stop();
			//timeout.removeEventListener(TimerEvent.TIMER_COMPLETE, timeoutHandler);
			
			if (isLoaded) {
				var delayTimer: Timer = new Timer(20, 1);
				delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, delayCompleteHandler, false, 0, true);
				delayTimer.start();
			}
			else {
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function delayCompleteHandler(e:TimerEvent):void {
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void {
			//timeout.stop();
			//timeout.removeEventListener(TimerEvent.TIMER_COMPLETE, timeoutHandler);
			Logger.info( "ImageLoader.ioErrorHandler >>>> e : " + e.text );
		}
	}

}