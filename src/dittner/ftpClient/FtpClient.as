package dittner.ftpClient {
import dittner.async.Async;
import dittner.async.CompositeCommand;
import dittner.ftpClient.cmd.AuthFtpCommand;
import dittner.ftpClient.cmd.QuitFtpCommand;
import dittner.ftpClient.cmd.UploadFtpCommand;
import dittner.ftpClient.utils.ServerInfo;

import flash.display.Stage;
import flash.filesystem.File;
import flash.net.Socket;

public class FtpClient {

	public function FtpClient(stage:Stage):void {
		cmdSocket = new Socket();
		Async.stage = stage;
	}

	private var cmdSocket:Socket;

	//----------------------------------------------------------------------------------------------
	//
	//  Methods
	//
	//----------------------------------------------------------------------------------------------

	private var uploadOp:CompositeCommand;
	private var uploadCmdState:FtpCmdState;
	public function upload(files:Array, serverInfo:ServerInfo):CompositeCommand {
		if (uploadOp && uploadOp.isProcessing) throw new Error("Upload is processing!");
		uploadCmdState = new FtpCmdState();
		uploadOp = new CompositeCommand();
		for (var i:int = 0; i < files.length; i++) {
			var f:File = files[i];
			if (!f.exists)
				uploadOp.dispatchError("Uploading file does not exist!");
			uploadOp.addProgressOperation(AuthFtpCommand, i / files.length, cmdSocket, serverInfo, uploadCmdState);
			uploadOp.addProgressOperation(UploadFtpCommand, 0.99 * (i + 1) / files.length, f, cmdSocket, serverInfo, uploadCmdState);
			uploadOp.addProgressOperation(QuitFtpCommand, (i + 1) / files.length, cmdSocket, serverInfo, uploadCmdState);
		}

		if (!serverInfo.host || !serverInfo.port || !serverInfo.user || !serverInfo.password)
			uploadOp.dispatchError("Server info is not fill!");
		else
			uploadOp.execute();

		return uploadOp;
	}

	public function close():void {
		if (uploadOp && uploadOp.isProcessing)
			uploadOp.dispatchError();
		if (uploadCmdState)
			uploadCmdState.isAborted = true;
		if (cmdSocket.connected)
			cmdSocket.close();
	}

}
}