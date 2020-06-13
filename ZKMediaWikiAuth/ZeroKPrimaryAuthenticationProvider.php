<?php
/**
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * http://www.gnu.org/copyleft/gpl.html
 *
 * @file
 * @ingroup Auth
 */

namespace MediaWiki\Extension\ZKMediaWikiAuth;

use MediaWiki\Auth\LocalPasswordPrimaryAuthenticationProvider;
use Status;
use MediaWiki\Auth\AuthenticationResponse;
use MediaWiki\Auth\AuthenticationRequest;
use MediaWiki\Auth\PasswordAuthenticationRequest;
use User;

require_once($IP."/includes/custom/bcrypt.php");
use Bcrypt;

/**
 * Authenticates the wiki user using their username and password on zero-k.info.
 * If the account exists and the password matches, the user is logged in;
 * else it attempts to fall back to MediaWiki's own user database.
 */
class ZeroKPrimaryAuthenticationProvider
	extends LocalPasswordPrimaryAuthenticationProvider
{
	
	public function beginPrimaryAuthentication( array $reqs ) {		
		$req = AuthenticationRequest::getRequestByClass( $reqs, PasswordAuthenticationRequest::class );
		if ( !$req ) {
			throw new \Exception( 'Failed to get request' );
			return AuthenticationResponse::newAbstain();
		}
	
		if ( $this->accountCreationType() === self::TYPE_NONE ) {
			throw new \BadMethodCallException( 'Shouldn\'t call this when accountCreationType() is NONE' );
		}
				
		//wfDebugLog( "ZKMediaWikiAuth", "Trying username: " . $req->username . ", password: " . $req->password);
		
		if ( $req->username === null || $req->password === null ) {
			return AuthenticationResponse::newAbstain();
		}

		$username = User::getCanonicalName( $req->username, 'usable' );
		if ( $username === false ) {
			return AuthenticationResponse::newAbstain();
		}

		$db = $this->connectToDB();
		$password = base64_encode(md5( $req->password, true ));
		
		if (is_null($db)) {
			throw new \Exception( 'Database is null' );
		}
		
		$query = sqlsrv_query( $db, "SELECT * FROM {$this->dbTable}
			WHERE LOWER({$this->userLoginField}) = LOWER('$username')" );
			
		//wfDebugLog( "ZKMediaWikiAuth", "Trying SQL query: " . $query);
			
		if( $query === false ) {
			$error = 'ZeroKPrimaryAuthenticationProvider::userExists(): DB query failed';
			wfDebugLog( "ZKMediaWikiAuth", $error . ': ' . print_r( sqlsrv_errors(), true ) . "\n" );
			return AuthenticationResponse::newAbstain();
		}

		$queryFetch = sqlsrv_fetch_array( $query );
		//wfDebugLog( "ZKMediaWikiAuth", "Trying SQL query fetch: " . $query);
		if( $queryFetch ) {
			//wfDebugLog( "ZKMediaWikiAuth", "Verifying password " . $password . ", " . $queryFetch["PasswordBcrypt"]);
			$bcrypt = new Bcrypt(10);
			
			// TODO: check if account actually exists and create it?
			if ($bcrypt -> verify($password, $queryFetch["PasswordBcrypt"]))
			{
				return AuthenticationResponse::newPass( $username );
			}
		}
		
		return AuthenticationResponse::newAbstain();
	}
	
	/**
	 * Check that the password is valid
	 *
	 * This should be called *before* validating the password. If the result is
	 * not ok, login should fail immediately.
	 *
	 * @param string $username
	 * @param string $password
	 * @return Status
	 */
	protected function checkPasswordValidity( $username, $password ) {
		return \User::newFromName( $username )->checkPasswordValidity( $password );
		//return true;
	}
	
	protected function setPasswordResetFlag( $username, Status $status, $data = null ) {
		
	}

	/**
	 * Get password reset data, if any
	 *
	 * @param string $username
	 * @param mixed $data
	 * @return object|null { 'hard' => bool, 'msg' => Message }
	 */
	protected function getPasswordResetData( $username, $data ) {
		return null;
	}

	/**
	 * Get expiration date for a new password, if any
	 *
	 * @param string $username
	 * @return string|null
	 */
	protected function getNewPasswordExpiry( $username ) {
		return null;
	}
	
	// Adapted from MS SQL Database Authentication 1.08 by Iaroslav Vassiliev, GPL v2 license
	protected function connectToDB()
	{
		if( !isset( $GLOBALS['wgMsSqlAuth_Host'] )
			|| !isset( $GLOBALS['wgMsSqlAuth_Username'] )
			|| !isset( $GLOBALS['wgMsSqlAuth_Password'] )
			|| !isset( $GLOBALS['wgMsSqlAuth_Database'] )
			|| !isset( $GLOBALS['wgMsSqlAuth_Table'] )
			|| !isset( $GLOBALS['wgMsSqlAuth_LoginField'] )
			|| !isset( $GLOBALS['wgMsSqlAuth_PasswordField'] )
			|| !isset( $GLOBALS['wgMsSqlAuth_EmailField'] )
			|| !isset( $GLOBALS['wgMsSqlAuth_RealNameField'] )) {
				$error = 'ZeroKPrimaryAuthenticationProvider::connectToDB(): Not all required global variables are set.';
				wfDebugLog( "ZKMediaWikiAuth", $error . "\n" );
				return null;
		}

		$this->dbHost = $GLOBALS['wgMsSqlAuth_Host'];
		$this->dbUser = $GLOBALS['wgMsSqlAuth_Username'];
		$this->dbPassword = $GLOBALS['wgMsSqlAuth_Password'];
		$this->dbName = $GLOBALS['wgMsSqlAuth_Database'];
		$this->dbTable = $GLOBALS['wgMsSqlAuth_Table'];
		$this->userLoginField = $GLOBALS['wgMsSqlAuth_LoginField'];
		$this->userPasswordField = $GLOBALS['wgMsSqlAuth_PasswordField'];
		$this->userEmailField = $GLOBALS['wgMsSqlAuth_EmailField'];
		$this->userRealNameField = $GLOBALS['wgMsSqlAuth_RealNameField'];

		$this->dbTimeoutSecs = 30;
		
		// This extension assumes we're using the non-PDO driver
		
		$dbConnectionInfo = array(
			'Database' => $this->dbName,
			'CharacterSet' => 'UTF-8'    // default encoding is Windows codepage
		);

		if( !empty( $this->dbUser ) ) {    // dbUser and dbPassword are not specified in Windows authentication
			$dbConnectionInfo['UID'] = $this->dbUser;
			$dbConnectionInfo['PWD'] = $this->dbPassword;
		}
		
		$db = sqlsrv_connect( $this->dbHost, $dbConnectionInfo );

		if( is_null($db) ) {
			$error = 'ZeroKPrimaryAuthenticationProvider::connectToDB(): DB failed to open';
			wfDebugLog( "ZKMediaWikiAuth", $error . ': ' . print_r( sqlsrv_errors(), true ) . "\n" );
			throw new Exception($error . ': ' . print_r( sqlsrv_errors(), true ));
			return null;
		}
		
		return $db;
	}
}
