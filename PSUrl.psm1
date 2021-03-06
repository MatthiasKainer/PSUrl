register PSCredentialStore;

$webclient = New-Object System.Net.WebClient;

function Get-BaseUrlAndPort {
	param (
		[parameter(Mandatory = $true)]
		[string]$url
	);
	$uri = new-object System.Uri($url.ToLower());
	"$($uri.Scheme)$($uri.SchemeDelimiter)$($uri.Host):$($uri.Port)";
}

function Set-UrlCredentials {
	param (
		[parameter(Mandatory = $true)]
		[System.Management.Automation.PsCredential]$credentials
	);
	
	$webclient.Credentials = $credentials;
}

function Set-UrlCredentialsFor {
	param (
		[parameter(Mandatory = $true)]
		[string]$url
	);
	
	Add-CredentialsToStore(Get-BaseUrlAndPort($url));
}

function Get-UrlContent
{
	param (
		[parameter(Mandatory = $true)]
		[Uri]$url
	);
	
	$baseUrl = Get-BaseUrlAndPort($url);
	if(In-CredentialStore($baseUrl)) {
		$webclient.Credentials = Get-CredentialStore($baseUrl);
	}
	
	if ($url.HostNameType -ne [System.UriHostNameType]::Dns) {
		throw "Invalid url type";
	}
	
	$webclient.DownloadString($url);
}

function Add-UrlContent {
	param (
		[Uri]$url,
		[string]$data
	);
	if ($url.HostNameType -ne [System.UriHostNameType]::Dns) {
		throw "Invalid url type";
	}
	
	$baseUrl = Get-BaseUrlAndPort($url);
	if(In-CredentialStore($baseUrl)) {
		$webclient.Credentials = Get-CredentialStore($baseUrl);
	}
	$webclient.Headers[[System.Net.HttpRequestHeader]::ContentType] = "application/x-www-form-urlencoded";
	return $webclient.UploadData($url, "PUT", [System.Text.Encoding]::ASCII.GetBytes($data));
}

function Set-UrlContent {
	param (
		[Uri]$url,
		[string]$data
	);
	if ($url.HostNameType -ne [System.UriHostNameType]::Dns) {
		throw "Invalid url type";
	}
	
	$baseUrl = Get-BaseUrlAndPort($url);
	if(In-CredentialStore($baseUrl)) {
		$webclient.Credentials = Get-CredentialStore($baseUrl);
	}
	$webclient.Headers[[System.Net.HttpRequestHeader]::ContentType] = "application/x-www-form-urlencoded";
	return $webclient.UploadData($url, "POST", [System.Text.Encoding]::ASCII.GetBytes($data));
}

Export-ModuleMember -function Set-UrlCredentials;
Export-ModuleMember -function Set-UrlCredentialsFor;
Export-ModuleMember -function Get-UrlContent;
Export-ModuleMember -function Add-UrlContent;
Export-ModuleMember -function Set-UrlContent;
