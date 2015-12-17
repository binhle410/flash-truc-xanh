package trucxanh.common.helpers {
	import com.ritz.framework.logging.Logger;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author ...
	 */
	public class MyURLLoader extends EventDispatcher {
		
		private var url: String;
		
		public var xml: XML;
		
		public function MyURLLoader(url: String) {
			loader(url);
		}
		
		private function load(url: String): void {
			this.url = url;
			var request: URLRequest = new URLRequest(url);
			var loader: URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);			
			if (url.indexOf(".xmlz") > 0 || url.indexOf(".z") > 0)	loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(request);
		}
		
		private function loaderCompleteHandler(e:Event):void {
			var loader: URLLoader = e.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
			if (url.indexOf(".xmlz") > 0 || url.indexOf(".z") > 0)	loader.data.uncompress();
			xml = new XML(loader.data);
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void {
			Logger.info( "MyURLLoader.ioErrorHandler > e : " + e );			
		}
	}

}