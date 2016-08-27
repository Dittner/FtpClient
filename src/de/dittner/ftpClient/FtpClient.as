package de.dittner.ftpClient {
import de.dittner.async.AsyncCallbacksLib;
import de.dittner.async.CompositeCommand;
import de.dittner.ftpClient.cmd.AuthFtpCommand;
import de.dittner.ftpClient.cmd.DownloadFtpCommand;
import de.dittner.ftpClient.cmd.QuitFtpCommand;
import de.dittner.ftpClient.cmd.UploadFtpCommand;
import de.dittner.ftpClient.utils.ServerInfo;

import flash.display.Stage;
import flash.filesystem.File;
import flash.net.Socket;

public class FtpClient {
	public function FtpClient(stage:Stage):void {
		cmdSocket = new Socket();
		AsyncCallbacksLib.stage = stage;
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

	private var downloadOp:CompositeCommand;
	private var downloadCmdState:FtpCmdState;
	public function download(files:Array, serverInfo:ServerInfo):CompositeCommand {
		if (downloadOp && downloadOp.isProcessing) throw new Error("Download is processing!");
		downloadCmdState = new FtpCmdState();
		downloadOp = new CompositeCommand();
		for (var i:int = 0; i < files.length; i++) {
			var f:File = files[i];
			downloadOp.addProgressOperation(AuthFtpCommand, i / files.length, cmdSocket, serverInfo, downloadCmdState);
			downloadOp.addProgressOperation(DownloadFtpCommand, 0.99 * (i + 1) / files.length, f, cmdSocket, serverInfo, downloadCmdState);
			downloadOp.addProgressOperation(QuitFtpCommand, (i + 1) / files.length, cmdSocket, serverInfo, downloadCmdState);
		}

		if (!serverInfo.host || !serverInfo.port || !serverInfo.user || !serverInfo.password)
			downloadOp.dispatchError("Server info is not fill!");
		else
			downloadOp.execute();

		return downloadOp;
	}

	public function close():void {
		if (uploadOp && uploadOp.isProcessing)
			uploadOp.dispatchError();
		if (uploadCmdState)
			uploadCmdState.isAborted = true;
		if (downloadOp && downloadOp.isProcessing)
			downloadOp.dispatchError();
		if (downloadCmdState)
			downloadCmdState.isAborted = true;
		if (cmdSocket.connected)
			cmdSocket.close();
	}

}
}