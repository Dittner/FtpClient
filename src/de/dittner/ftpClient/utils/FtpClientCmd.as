package de.dittner.ftpClient.utils {
/**
 * @see: http://www.faqs.org/rfcs/rfc959.html
 */
public final class FtpClientCmd {
	public static const USER:String = "USER";
	public static const PASS:String = "PASS";
	public static const ACCT:String = "ACCT";
	public static const CWD:String = "CWD";
	public static const CDUP:String = "CDUP";
	public static const SMNT:String = "SMNT";
	public static const QUIT:String = "QUIT";
	public static const REIN:String = "REIN";
	public static const PORT:String = "PORT";
	public static const PASV:String = "PASV";
	public static const TYPE:String = "TYPE";
	public static const STRU:String = "STRU";
	public static const MODE:String = "MODE";
	public static const RETR:String = "RETR";
	public static const STOR:String = "STOR";
	public static const STOU:String = "STOU";
	public static const APPE:String = "APPE";
	public static const ALLO:String = "ALLO";
	public static const REST:String = "REST";
	public static const RNFR:String = "RNFR";
	public static const RNTO:String = "RNTO";
	public static const ABOR:String = "ABOR";
	public static const DELE:String = "DELE";
	public static const RMD:String = "RMD";
	public static const MKD:String = "MKD";
	public static const PWD:String = "PWD";
	public static const LIST:String = "LIST";
	public static const NLST:String = "NLST";
	public static const SITE:String = "SITE";
	public static const SYST:String = "SYST";
	public static const STAT:String = "STAT";
	public static const HELP:String = "HELP";
	public static const NOOP:String = "NOOP";

	//Known:
	public static const FEAT:String = "FEAT";
	public static const SIZE:String = "SIZE";

	//Shortcuts:
	public static const TYPE_BINARY:String = "TYPE I";
	public static const TYPE_TEXT:String = "TYPE A";
}
}