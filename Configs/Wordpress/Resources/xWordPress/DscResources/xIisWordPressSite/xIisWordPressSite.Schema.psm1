# Composite configuration to install the IIS WordPress IIS site
# This does not setup the actual WordPress Site
configuration xIisWordPressSite
{
        param
    (
        [Parameter(Mandatory = $true)]
        [PSCredential] $DbUser,

        [string] $WordPressIisSiteName = 'Wordpress',
        
        [string] $WordPressSiteDirectory = '%systemdrive%\inetpub\Wordpress',

        [string] $DownloadUri = 'http://wordpress.com/latest.zip',

        [string] $DatabaseName = 'Wordpress',
        
        [string] $DbHostName = 'Localhost',

        [string] $DbTablePrefix = 'wp_'
    )
    Import-DscResource -module xPsDesiredStateConfiguration
    Import-DscResource -module xWebAdministration

    $TemporaryPath = "c:\DSCWordpressFiles"
    $WordPressZip = Join-Path $TemporaryPath "WordPress.zip"
    $WordPressUnzipLocation = Split-Path $WordPressSiteDirectory -Parent
    $DBUserName = $DbUser.GetNetworkCredential().UserName
    $DBPassword = $DbUser.GetNetworkCredential().password

    # Make sure the WordPress archive is in the package folder
    xRemoteFile WordPressArchive 
    {
        Uri               = $DownloadUri
        DestinationPath   = $WordPressZip
    }

    # Make sure the WordPress site folder is present and copy content from extracted archive
    File WordpressFolder
    {
        Ensure = 'Present'
        Type = 'Directory'
        DestinationPath = $WordPressSiteDirectory
    }

    # Make sure the WordPress archive contents are in the WordPress root folder
    xArchive WordPress
    {
        Path              = $WordPressZip 
        Destination       = $WordPressUnzipLocation 
        DependsOn         = "[xRemoteFile]WordPressArchive", "[File]WordpressFolder"
    }

    # Make sure the WordPress configuration file is present
    File WordPressConfig
    {
        Contents          = New-WordpressConfig -DatabaseName $DatabaseName -DbUserName $DBUserName -DbPassword $DBPassword -DbHostName $DbHostName -DbTablePrefix $DbTablePrefix
        DestinationPath   = Join-Path $WordPressSiteDirectory "wp-config.php"
        MatchSource       = $true
        DependsOn         = "[File]WordpressFolder"
    }

    # Make sure the WordPress Iis site is present
    xWebSite WordPressIisSite
    {
        Ensure            = "Present"
        State             = "Started"
        Name              = $WordPressIisSiteName
        PhysicalPath      = $WordPressSiteDirectory
        DefaultPage       = "index.php"
        DependsOn         = "[xArchive]WordPress", "[File]WordPressConfig"
    }
    
    # Remove the directory where     
    file Tempdirectory
    {
        Ensure            = "Absent"
        Type              = "Directory"
        DestinationPath   = $TemporaryPath
        Recurse           = $true
        Force             = $true
    }
}

#TODO: Make the configuration configurable, idempotent and non-distructive

Function New-WordpressConfig
{
    param
    (
            [Parameter(Mandatory = $true)]
            [string] $DatabaseName,

            [Parameter(Mandatory = $true)]
            [string] $DbUserName,

            [Parameter(Mandatory = $true)]
            [string] $DbPassword,

            [Parameter(Mandatory = $true)]
            [string] $DbHostName,

            [string] $DbTablePrefix = 'wp_'
    )

    # Evaluate the string and return it.
    return @"
    <?php
    /**
     * Custom WordPress configurations on "wp-config.php" file.
     *
     * This file has the following configurations: MySQL settings, Table Prefix, Secret Keys, WordPress Language, ABSPATH and more.
     * For more information visit {@link http://codex.wordpress.org/Editing_wp-config.php Editing wp-config.php} Codex page.
     * Created using {@link http://generatewp.com/wp-config/ wp-config.php File Generator} on GenerateWP.com.
     *
     * @package WordPress
     * @generator GenerateWP.com
     */


    /* MySQL settings */
    define( 'DB_NAME',     '$DatabaseName' );
    define( 'DB_USER',     '$DbUserName' );
    define( 'DB_PASSWORD', '$DbPassword' );
    define( 'DB_HOST',     '$DbHostName' );
    define( 'DB_CHARSET',  'utf8' );


    /* MySQL database table prefix. */
    `$table_prefix = '$DbTablePrefix';

    /**Secrets#
    /* Authentication Unique Keys and Salts. */
    define('AUTH_KEY',         'A+*GsxEq2nUwk6>r1nq-KZ>QEMAescGQ =ABPb8XZC5GBT6e{rNN{2q%m+*2Olm{');
    define('SECURE_AUTH_KEY',  'Cu-`M;u{;EOvLG]#-%?!<.-W+JUd;]V-mp');
    define('SECURE_AUTH_SALT', 'wxL+^S{ZbHt2EuH-X}:b=qxA9a< K?JUn2|Pd!C,gMS)[j?-cU/7RI|a<&LMy[;O');
    define('LOGGED_IN_SALT',   'X%M60z[N7Ra?/{~C3hE%7WjMPnJU-u-Ds]1Of,`K=T&Qm (>/pjfy^Om]w _d<(-');
    define('NONCE_SALT',       '31NY);q.~W[K},#1>z9}AU:(Jh?Tm-l1Zo))b@`{Ho,j)tuK)|=2a=(E,{zxz*;e');
    #Secrets**/

    /* WordPress Localized Language. */
    define( 'WPLANG', '' );




    /* Media Trash. */
    define( 'MEDIA_TRASH', true );


    /* Multisite. */
    define( 'WP_ALLOW_MULTISITE', true );

    /* Absolute path to the WordPress directory. */
    if ( !defined('ABSPATH') )
	    define('ABSPATH', dirname(__FILE__) . '/');

    /* Sets up WordPress vars and included files. */
    require_once(ABSPATH . 'wp-settings.php');
"@

}

