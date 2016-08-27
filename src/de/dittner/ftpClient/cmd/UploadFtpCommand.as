package de.dittner.ftpClient.cmd {
import de.dittner.ftpClient.FtpCmdState;
import de.dittner.ftpClient.utils.FtpClientCmd;
import de.dittner.ftpClient.utils.FtpServerCmd;
import de.dittner.ftpClient.utils.ServerInfo;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.OutputProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.Socket;
import flash.utils.ByteArray;

public class UploadFtpCommand extends FtpCommand {
	public function UploadFtpCommand(file:File, cmdSocket:Socket, serverInfo:ServerInfo, state:FtpCmdState) {
		super(cmdSocket, serverInfo, state);
		this.file = file;
	}

	private var file:File;
	private var fileStream:FileStream;
	private var fileTotalBytesNum:Number = 0;
	private var dataSocket:Socket;
	private static const STREAM_BUFFER:uint = 1024 * 50;//50 Kb

	override public function execute():void {
		if (state.isAuthenticated) {
			fileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			fileTotalBytesNum = fileStream.bytesAvailable;

			if (serverInfo.remoteDirPath) {
				isClientCmdNavFolder = true;
				if(traceEnabled) trace("Client: CWD " + serverInfo.remoteDirPath);
				cmdSocket.writeUTFBytes(FtpClientCmd.CWD + " " + serverInfo.remoteDirPath + CRLF);
				cmdSocket.flush();
			}
			else {
				if(traceEnabled) trace("Client: TYPE I");
				cmdSocket.writeUTFBytes(FtpClientCmd.TYPE_BINARY + CRLF); //set data as binary
				if(traceEnabled) trace("Client: PASV");
				cmdSocket.writeUTFBytes(FtpClientCmd.PASV + CRLF); //use passive mode
				cmdSocket.flush();
			}
		}
		else {
			dispatchError("Upload required authenticated user!");
		}
	}

	private var isClientCmdNavFolder:Boolean = false;
	override protected function cmdFromServer(cmdNum:uint, cmd:String):void {
		switch (cmdNum) {
			case FtpServerCmd.NOT_FOUND:
				if (isClientCmdNavFolder) {
					isClientCmdNavFolder = false;
					//create folder
					if(traceEnabled) trace("Client: MKD " + serverInfo.remoteDirPath);
					cmdSocket.writeUTFBytes(FtpClientCmd.MKD + " " + serverInfo.remoteDirPath + CRLF);
					cmdSocket.flush();
				}
				else dispatchError(cmd);
				break;
			case FtpServerCmd.FOLDER_CREATED:
				//navigate to created folder
				if(traceEnabled) trace("Client: CWD " + serverInfo.remoteDirPath);
				cmdSocket.writeUTFBytes(FtpClientCmd.CWD + " " + serverInfo.remoteDirPath + CRLF);
				cmdSocket.flush();
				break;
			case FtpServerCmd.FILE_ACTION_OK:
				//set binary mode
				if(traceEnabled) trace("Client: TYPE I");
				cmdSocket.writeUTFBytes(FtpClientCmd.TYPE_BINARY + CRLF); //set data as binary
				if(traceEnabled) trace("Client: PASV");
				cmdSocket.writeUTFBytes(FtpClientCmd.PASV + CRLF); //use passive mode
				cmdSocket.flush();
				break;
			case FtpServerCmd.COMMAND_OK:
				//ignore
				break;
			case FtpServerCmd.ENTERING_PASV:
				//Entering passive mode
				//Passive mode message example: 227 Entering Passive Mode (288,120,88,233,161,214)
				//And interpretation: IP is 288.120.88.233, and PORT is 161*256+214 = 41430
				if (!dataSocket) {
					var match:Array = cmd.match(/(\d{1,3},){5}\d{1,3}/);
					if (match == null) {
						dispatchError("Error parsing passive port! (" + cmd + ")");
						return;
					}
					var data:Array = match[0].split(",");
					var host:String = data.slice(0, 4).join(".");
					var port:int = (parseInt(data[4]) << 8) + parseInt(data[5]);

					openDataSocket(host, port);
				}
				break;
			case FtpServerCmd.FILE_STATUS_OK:
				sendFileBytes();
				break;
			case FtpServerCmd.DATA_CONN_CLOSE:
				dispatchSuccess();
				break;
			case FtpServerCmd.CLOSING_CONTROL_CONN:
				state.isConnectionClosed = true;
				dispatchError("Connection is closed");
				break;
			default :
				if (cmdNum >= 500) dispatchError(cmd);
				else dispatchError("Unhandled cmd from server: " + cmdNum);
		}
	}

	private function openDataSocket(host:String, port:int):void {
		dataSocket = new Socket();
		dataSocket.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onDataSocketAnswered);
		dataSocket.addEventListener(Event.CONNECT, onDataSocketConnected);
		dataSocket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
		dataSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		dataSocket.addEventListener(Event.CLOSE, onConnectionClosed);
		dataSocket.connect(host, port);
	}

	private function onDataSocketAnswered(e:OutputProgressEvent):void {
		if (e.bytesPending == 0) sendFileBytes();
	}

	protected function onDataSocketConnected(e:Event):void {
		if(traceEnabled) trace("Client: STOR " + file.nativePath);
		cmdSocket.writeUTFBytes(FtpClientCmd.STOR + " " + file.name + CRLF);
		cmdSocket.flush();
	}

	private var buffer:ByteArray = new ByteArray();
	private function sendFileBytes():void {
		buffer.clear();

		if (fileStream.bytesAvailable <= 0) {
			dataSocket.close();
			setProgress(1);
		}
		else { //if something gets wrong and after first try there is still data available
			//load fileStream data to byteArray
			fileStream.readBytes(buffer, 0, fileStream.bytesAvailable < STREAM_BUFFER ? fileStream.bytesAvailable : STREAM_BUFFER);
			dataSocket.writeBytes(buffer, 0, buffer.bytesAvailable); //save byteArray via data socket
			dataSocket.flush();
			setProgress(1 - fileStream.bytesAvailable / fileTotalBytesNum);
		}
	}

	override public function destroy():void {
		super.destroy();
		if (dataSocket) {
			dataSocket.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onDataSocketAnswered);
			dataSocket.removeEventListener(Event.CONNECT, onDataSocketConnected);
			dataSocket.removeEventListener(IOErrorEvent.IO_ERROR, onSocketError);
			dataSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			dataSocket.removeEventListener(Event.CLOSE, onConnectionClosed);
			dataSocket = null;
		}
	}
}
}
