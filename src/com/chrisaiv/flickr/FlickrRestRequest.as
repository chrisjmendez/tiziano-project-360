package src.flickr
{
	import com.adobe.serialization.json.JSON;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class FlickrRestRequest extends EventDispatcher
	{
		public function FlickrRestRequest()
		{
		}

		//This is a very generic Flickr JSON REST Request.  
		//If you're making any Flickr request, your doing it here
        public function load( flickr_api:String, restMethod:String, targetParam:String, id:String ):void
        {
        	var urlVars:URLVariables = new URLVariables();
        		urlVars.method = restMethod;
        		urlVars.api_key = flickr_api;
        		urlVars[targetParam] = id;
        		urlVars.format = "json";
        		urlVars.cache_clear = new Date().getTime();
        	
        	var urlRequest:URLRequest = new URLRequest();
        		urlRequest.url = "http://api.flickr.com/services/rest/";
        		urlRequest.method = URLRequestMethod.GET;
        		urlRequest.data = urlVars;

            var urlLoader:URLLoader = new URLLoader();
                urlLoader.addEventListener( Event.COMPLETE, flickrRestRequestComplete );
                urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
                urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
                urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
                urlLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
                urlLoader.load( urlRequest );
        }

        private function flickrRestRequestComplete( e:Event ):void
        {
			//var rawData = 'jsonFlickrApi({"stat":"fail", "code":105, "message":"Service currently unavailable (API Disabled)"})';
	        var rawData = e.currentTarget.data;
			var data:String = rawData.slice( rawData.indexOf("{"), rawData.lastIndexOf("}") + 1 );
	        var json:Object = JSON.decode( data ) as Object;
	        
	        if( json.stat == "fail" ) trace();
        	//Basically, whatever data is returned, we're going to dispatch and event and pass that data along
	        else dispatchEvent( new FlickrEvent( FlickrEvent.CUSTOM, json ) );
        }
        
		/***********************************
		 * Event Handlers :: Error Events
		***********************************/
		private function httpStatusHandler ( e:HTTPStatusEvent ):void
		{
		        //trace("FlickrRestRequest::httpStatusHandler:" + e);
		}
		
		private function securityErrorHandler ( e:SecurityErrorEvent ):void
		{
		        trace("FlickrRestRequest::securityErrorHandler: " + e);
		}
		
		private function ioErrorHandler( e:IOErrorEvent ):void
		{
		 	     trace("FlickrRestRequest::ioErrorHandler: " + e);
		}
		
		private function progressHandler( e:ProgressEvent ):void
		{
		        //trace("FlickrRestRequest:: " + e.currentTarget.bytesLoaded + " / " + e.currentTarget.bytesTotal);
		}
        
	}
}