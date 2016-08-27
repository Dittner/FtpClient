package de.dittner.ftpClient.cmd {
import de.dittner.ftpClient.FtpCmdState;
import de.dittner.ftpClient.utils.FtpClientCmd;
import de.dittner.ftpClient.utils.FtpServerCmd;
import de.dittner.ftpClient.utils.ServerInfo;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.Socket;
import flash.utils.ByteArray;

public class DownloadFtpCommand extends FtpCommand {
	public function DownloadFtpCommand(file:File, cmdSocket:Socket, serverInfo:ServerInfo, state:FtpCmdState) {
		super(cmdSocket, serverInfo, state);
		this.file = file;
	}

	private var file:File;
	private var fileStream:FileStream;
	private var fileTotalBytesNum:Number = 0;
	private var dataSocket:Socket;

	override public function execute():void {
		if (state.isAuthenticated) {
			fileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.position = 0;

			if (serverInfo.remoteDirPath) {
				isClientCmdNavFolder = true;
				if (traceEnabled) trace("Client: CWD " + serverInfo.remoteDirPath);
				cmdSocket.writeUTFBytes(FtpClientCmd.CWD + " " + serverInfo.remoteDirPath + CRLF);
				cmdSocket.flush();
			}
			else {
				if (traceEnabled) trace("Client: TYPE I");
				cmdSocket.writeUTFBytes(FtpClientCmd.TYPE_BINARY + CRLF); //set data as binary
				if (traceEnabled) trace("Client: PASV");
				cmdSocket.writeUTFBytes(FtpClientCmd.PASV + CRLF); //use passive mode
				cmdSocket.flush();
			}
		}
		else {
			dispatchError("Upload required authenticated user!");
		}
	}

	private static const BYTES_PATTERN:RegExp = /(\d*) bytes/;
	private var isClientCmdNavFolder:Boolean = false;
	override protected function cmdFromServer(cmdNum:uint, cmd:String):void {
		switch (cmdNum) {
			case FtpServerCmd.NOT_FOUND:
				if (isClientCmdNavFolder) {
					isClientCmdNavFolder = false;
					//create folder
					if (traceEnabled) trace("Client: MKD " + serverInfo.remoteDirPath);
					cmdSocket.writeUTFBytes(FtpClientCmd.MKD + " " + serverInfo.remoteDirPath + CRLF);
					cmdSocket.flush();
				}
				else dispatchError(cmd);
				break;
			case FtpServerCmd.FOLDER_CREATED:
				//navigate to created folder
				if (traceEnabled) trace("Client: CWD " + serverInfo.remoteDirPath);
				cmdSocket.writeUTFBytes(FtpClientCmd.CWD + " " + serverInfo.remoteDirPath + CRLF);
				cmdSocket.flush();
				break;
			case FtpServerCmd.FILE_ACTION_OK:
				//set binary mode
				if (traceEnabled) trace("Client: TYPE I");
				cmdSocket.writeUTFBytes(FtpClientCmd.TYPE_BINARY + CRLF); //set data as binary
				if (traceEnabled) trace("Client: PASV");
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
				if (traceEnabled) trace("Client: Reading File size: " + cmd);
				//"150 Opening BINARY mode data connection for file.db (12293120 bytes)."
				var regRes:Array = BYTES_PATTERN.exec(cmd);
				fileTotalBytesNum = regRes.length <= 2 || isNaN(regRes[1]) ? regRes[1] : 0;
				readFileBytes();
				break;
			case FtpServerCmd.DATA_CONN_CLOSE:
				//ignore, we are waiting, while all data loaded
				break;
			case FtpServerCmd.CLOSING_CONTROL_CONN:
				state.isConnectionClosed = true;
				dispatchError("Connection is closed");
				break;
			default :
				if (cmdNum >= 500)
					dispatchError(cmd);
				else
					dispatchError("Unhandled cmd from server: " + cmdNum);
		}
	}

	private function openDataSocket(host:String, port:int):void {
		dataSocket = new Socket();
		dataSocket.addEventListener(ProgressEvent.SOCKET_DATA, onDataSocketLoaded);
		dataSocket.addEventListener(Event.CONNECT, onDataSocketConnected);
		dataSocket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
		dataSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		dataSocket.addEventListener(Event.CLOSE, onConnectionClosed);
		dataSocket.connect(host, port);
	}

	private function onDataSocketLoaded(e:ProgressEvent):void {
		readFileBytes();
	}

	protected function onDataSocketConnected(e:Event):void {
		if (traceEnabled) trace("Client: RETR " + file.nativePath);
		cmdSocket.writeUTFBytes(FtpClientCmd.RETR + " " + file.name + CRLF);
		cmdSocket.flush();
	}

	private var buffer:ByteArray = new ByteArray();
	private function readFileBytes():void {
		dataSocket.readBytes(buffer, 0, buffer.bytesAvailable);
		fileStream.writeBytes(buffer, 0, buffer.bytesAvailable);
		buffer.clear();
		if (fileTotalBytesNum != 0) {
			setProgress(fileStream.position / fileTotalBytesNum);
			if (fileStream.position == fileTotalBytesNum)
				dispatchSuccess();
		}
	}

	override public function destroy():void {
		super.destroy();
		if (dataSocket) {
			dataSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onDataSocketLoaded);
			dataSocket.removeEventListener(Event.CONNECT, onDataSocketConnected);
			dataSocket.removeEventListener(IOErrorEvent.IO_ERROR, onSocketError);
			dataSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			dataSocket.removeEventListener(Event.CLOSE, onConnectionClosed);
			dataSocket = null;
		}
		if (fileStream) {
			fileStream.close();
			fileStream = null;
		}
	}
}
}
