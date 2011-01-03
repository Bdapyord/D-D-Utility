package org.medawar.DualViewer.map {
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.XMLSocket;
	
	import mx.controls.Alert;
	
	import org.medawar.DualViewer.scripts.IXMLReciver;
	
	import spark.components.TextArea;
	
	public class SocketClient extends Sprite
	{

		

			private var serverURL:String;
			private var portNumber:int;
			private var socket:XMLSocket;
			private var reciver:IXMLReciver;

			public function SocketClient(server:String, port:int, reciver:IXMLReciver)
			{
				serverURL = server;
				portNumber = port;
				this.reciver = reciver;
				socket = new XMLSocket();
				configureListeners(socket);
				socket.connect(serverURL, portNumber);
			}
			
			public function send(data:Object):void {
				if(data!= null)
				socket.send(data);
			}
			
			private function configureListeners(dispatcher:IEventDispatcher):void {
				dispatcher.addEventListener(Event.CLOSE, closeHandler);
				dispatcher.addEventListener(Event.CONNECT, connectHandler);
				dispatcher.addEventListener(DataEvent.DATA, dataHandler);
				dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			}
			
			private function closeHandler(event:Event):void {
				trace("closeHandler: " + event);
			}
			
			private function connectHandler(event:Event):void {
				trace("connectHandler: " + event);
			}
			
			private function dataHandler(event:DataEvent):void {
				trace("dataHandler: " + event);
				reciver.recive(new XML(event.data));
			}
			
			private function ioErrorHandler(event:IOErrorEvent):void {
				trace("ioErrorHandler: " + event);
			}
			
			private function progressHandler(event:ProgressEvent):void {
				trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
			}
			
			private function securityErrorHandler(event:SecurityErrorEvent):void {
				trace("securityErrorHandler: " + event);
			}

			

	
		}
	
	}