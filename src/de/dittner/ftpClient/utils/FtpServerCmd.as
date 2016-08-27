package de.dittner.ftpClient.utils {
/**
 * @see: http://www.faqs.org/rfcs/rfc959.html
 */
public final class FtpServerCmd {
		//500 Series: The command was not accepted and the requested action did not take place.
		public static const UNRECOGNIZED:int 				= 500; 	//Syntax error, command unrecognized. This may include errors such as command line too long.
		public static const PARAM_ERROR:int 				= 501; 	//Syntax error in parameters or arguments.
		public static const NOT_IMPLEMENTED:int 			= 502; 	//Command not implemented.
		public static const BAD_SEQUENCE:int 				= 503; 	//Bad sequence of commands.
		public static const NOT_IMPL_FOR_PARAM:int 			= 504; 	//Command not implemented for that parameter.
		public static const NOT_LOGGED:int 					= 530; 	//Not logged in.
		public static const NEED_ACCOUNT_FOR_STOR:int 		= 532; 	//Need account for storing files.
		public static const NOT_FOUND:int 					= 550; 	//Requested action not taken. File unavailable (e.g., file not found, no access).
		public static const PAGE_UNKNOWN:int 				= 551; 	//Requested action aborted. Page type unknown.
		public static const EXCEEDED_STORAGE:int 			= 552; 	//Requested file action aborted. Exceeded storage allocation (for current directory or dataset).
		public static const FILENAME_NOT_ALLOWED:int 		= 553; 	//Requested action not taken. File name not allowed.
		
		//400 Series: The command was not accepted and the requested action did not take place, but the error condition is temporary and the action may be requested again.
		public static const SERVICE_NOT_AVAIL:int 		= 421; 	//Service not available, closing control connection.This may be a reply to any command if the service knows it must shut down.
		public static const CANT_OPEN_DATA_CONN:int 	= 425; 	//Can't open data connection.
		public static const CONNECTION_CLOSED:int 		= 426;	//Connection closed; transfer aborted.
		public static const FILE_ACTION_NOT_TAKEN:int 	= 450; 	//Requested file action not taken.
		public static const LOCAL_ERROR:int 			= 451; 	//Requested action aborted. Local error in processing.
		public static const INSUFF_STORAGE:int 			= 452; 	//Requested action not taken. Insufficient storage space in system.File unavailable (e.g., file busy).
		
		//300 Series: The command has been accepted, but the requested action is dormant, pending receipt of further information.
		public static const USER_OK:int 		= 331; 	//User name okay, need password.
		public static const NEED_ACCOUNT:int 	= 332; 	//Need account for login.
		public static const MORE_INFO:int 		= 350;	//Requested file action pending further information

		//200 Series: The requested action has been successfully completed.
		public static const COMMAND_OK:int 				= 200; 	//Command okay.
		public static const COMMAND_NOT_IMPLEMENTED:int = 202; 	//Command not implemented, superfluous at this site.
		public static const SYSTEM_STATUS:int 			= 211; 	//System status, or system help reply.
		public static const DIRECTORY_STATUS:int 		= 212; 	//Directory status.
		public static const FILE_STATUS:int 			= 213; 	//File status.
		public static const HELP_MESSAGE:int 			= 214; 	//Help message.On how to use the server or the meaning of a particular non-standard command. This reply is useful only to the human user.
		public static const SYS_TYPE:int 				= 215; 	//NAME system type. Where NAME is an official system name from the list in the Assigned Numbers document.
		public static const SERVICE_READY:int 			= 220; 	//Service ready for new user.
		public static const CLOSING_CONTROL_CONN:int 	= 221; 	//Service closing control connection.
		public static const DATA_CONN_OPEN:int 			= 225; 	//Data connection open; no transfer in progress.
		public static const DATA_CONN_CLOSE:int 		= 226; 	//Closing data connection. Requested file action successful (for example, file transfer or file abort).
		public static const ENTERING_PASV:int 			= 227; 	//Entering Passive Mode (h1,h2,h3,h4,p1,p2).
		public static const LOGGED_IN:int 				= 230; 	//User logged in, proceed. Logged out if appropriate.
		public static const FILE_ACTION_OK:int 			= 250; 	//Requested file action okay, completed.
		public static const FOLDER_CREATED:int 	    	= 257; 	//"PATHNAME" created.

		//100 Series: The requested action is being initiated, expect another reply before proceeding with a new command.
		public static const RESTART_MARKER:int 			= 110; 	//Restart marker reply. In this case, the text is exact and not left to the particular implementation; it must read: MARK yyyy = mmmm where yyyy is User-process data stream marker, and mmmm server's equivalent marker (note the spaces between markers and "=").
		public static const READY_IN_N_MINUTES:int 		= 120; 	//Service ready in nnn minutes.
		public static const DATA_CONN_ALREADY_OPEN:int 	= 125; 	//Data connection already open; transfer starting.
		public static const FILE_STATUS_OK:int 			= 150; 	//File status okay; about to open data connection.
	}
}