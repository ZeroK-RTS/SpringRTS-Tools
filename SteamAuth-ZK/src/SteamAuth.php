<?php
// Imports
use MediaWiki\Auth\AuthManager;
use MediaWiki\Auth\AuthenticationRequest;
use MediaWiki\MediaWikiServices;
use MediaWiki\Session\SessionManager;

/*
	Modified by Histidine for Zero-K login
	It checks the Steam ID against the ZK player database to get the desired username
*/
class SteamAuth extends PluggableAuth {
	public function authenticate( &$id, &$username, &$realname, &$email, &$errorMessage ) {
        // Get config options
        $config = MediaWikiServices::getInstance()->getConfigFactory()->makeConfig( 'SteamAuth' ); // Get the config
        $steamapi = $config->get( 'SteamAuth_Key' );
        $appid = $config->get( 'SteamAuth_AppID' );

        // AuthManager for managing the session
        $authManager = AuthManager::singleton();

        try {
            // Create LightOpenID that directs back to this session
            $openid = new LightOpenID($authManager->getAuthenticationSessionData(PluggableAuthLogin::RETURNTOURL_SESSION_KEY));
            
            // If the LightOpenID hasn't started send the user to Steam (eventually display the login page)
            if(!$openid->mode) {
                // Check if the button was clicked
                $isLoggingIn = $authManager->getAuthenticationSessionData(PluggableAuthLogin::EXTRALOGINFIELDS_SESSION_KEY);

                if(isset($isLoggingIn['steam'])) {
                    $openid->identity = 'https://steamcommunity.com/openid/?l=english'; // Force english so a random lang is not selected
                    header('Location: ' . $openid->authUrl());
                    exit;
                } else {
                    // Show the login page
                    $errorMessage = '';
                    return false;
                }
            } else if ($openid->mode == 'cancel') {
                // Tell the user they canceled auth
                $errorMessage = 'User has canceled authentication.';
                return false;
            } else {
                // Validate the login and sign the user in
                if($openid->validate()) {
                    $sidurl = $openid->identity; // Steam ID Url

                    // Get only the ID of the user
                    $ptn = "/^https:\/\/steamcommunity\.com\/openid\/id\/(7[0-9]{15,25}+)\/?$/";
                    preg_match($ptn, $sidurl, $matches);

                    // Get the user's info
                    $url = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" . $steamapi . "&steamids=" . $matches[1] . "&format=json";
                    $json_object= file_get_contents($url);
                    $json_decoded = json_decode($json_object);

                    $player = $json_decoded->response->players[0];

                    // Check if the appid has been specified
                    if ($appid != null) {
                        // If the appid has been specified look if the user has it
                        $hasgame = false; // Has game var

                        // Get the users games
                        $url = "https://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=" . $steamapi . "&steamid=" . $matches[1] . "&format=json&include_played_free_games=true";
                        $json_object= file_get_contents($url);
                        $json_decoded = json_decode($json_object);

                        // If a game has the appid update the hasgame var
                        $games = $json_decoded->response->games;
                        foreach ($games as &$game) {
                            if ($game->appid == $appid) {
                                $hasgame = true;
                            }
                        }

                        // Pass or fail login
                        if ($hasgame) {
                            // Log user in if they have the game
                            $id = $player->steamid;
                            $username = $player->steamid;
                            $realname = $player->personaname;
                            
                            return true;
                        } else {
                            // Don't log the user in if they dont have the game
                            $errorMessage = "User does not have the correct game. (Please make sure your \"Game Details\" are set to public)";
                            return false;
                        }
                    } else {
                        // If the appid has not been specified then log the user in
                        #$id = $player->steamid;
                        #$username = $player->steamid;
                        #$realname = $player->personaname;
						
						$db = $this->connectToDB();
						
						if (is_null($db)) {
							$error = 'SteamAuth::authenticate(): DB does not exist';
							wfDebugLog( "SteamAuth (ZK modded)", $error . ': ' . print_r( sqlsrv_errors(), true ) . "\n" );
							return false;
						}
						
						wfDebugLog("SteamAuth (ZK modded)", "Trying Steam ID ". $player->steamid);
						$query = sqlsrv_query( $db, "SELECT * FROM {$this->dbTable}
							WHERE {$this->userSteamIDField} = {$player->steamid}" );
							
						if( $query === false ) {
							$error = 'ZeroKPrimaryAuthenticationProvider::userExists(): DB query failed';
							wfDebugLog( "SteamAuth (ZK modded)", $error . ': ' . print_r( sqlsrv_errors(), true ) . "\n" );
							return AuthenticationResponse::newAbstain();
						}

						$queryFetch = sqlsrv_fetch_array( $query );
						if( $queryFetch ) {
							wfDebugLog("SteamAuth (ZK modded)", "Found account " . $queryFetch["Name"]);
							$username = $queryFetch["Name"];
							$realname = $player->personaname;
							return true;
						} else {
							wfDebugLog("SteamAuth (ZK modded)", "Query fetch is null");
						}                   
                        return false;
                    }                    
                } else {
                    // If the login wasn't valid tell the user
                    $errorMessage = 'User is not logged in.';
                    return false;
                }
            }
        }  catch ( Exception $e ) {
            // Log if something goes wrong
            wfDebugLog( 'Steam Auth', $e->__toString() . PHP_EOL );
            $errorMessage = $e->__toString();
            return false;
		}
    }
    
	public function deauthenticate( User &$user ) {
        return true;
    }
    
	public function saveExtraAttributes( $id ) {
        
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
		$this->userSteamIDField = $GLOBALS['wgMsSqlAuth_SteamIDField'];
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