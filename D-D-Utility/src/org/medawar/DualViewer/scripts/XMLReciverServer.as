package org.medawar.DualViewer.scripts
{
	import flashx.textLayout.tlf_internal;

	public class XMLReciverServer implements IXMLReciver
	{
		private var viewer:DualViewerMaster;

		public function setViewer(	viewerREC:DualViewerMaster):void{
			this.viewer = viewerREC;
		}
		public function recive(message:XML):void
		{
			
		}
	}
}