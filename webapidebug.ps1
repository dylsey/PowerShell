
#GET/{service}/{version}/{profile}/{coordinates}[.{format}]?option=value option=value
$BaseUrl = 'https://router.project-osrm.org'
$Service = 'route'
$Version = 'v1'
$TransportationProfile = 'driving'
$Coordinates = @{
    FromLongitude   = '-93.045507'
    FromLatitude    = '35.024966'
    ToLongitude     = '-94.166564'
    ToLatitude      = '36.071455'
}

#coordinate String
$CoordinateString = "$($Coordinates.FromLongitude),$($Coordinates.FromLatitude);$($Coordinates.ToLongitude),$($Coordinates.ToLatitude)"

$Format = '.json'

$RouteOptions = [ordered]@{
    Alternatives = 'alternatives=false'
    Steps = 'steps=false'
    Annotations = 'annotations=distance'
    Overview = 'overview=false'
    ContinueStraight = 'continue_straight=true'
}

$RouteOptionString = ($RouteOptions.Values) -join "&"

Write-Output "Route Options String: $RouteOptionString"

$FullUrl = "$BaseUrl/$Service/$Version/$TransportationProfile/$CoordinateString${Format}?$RouteOptionString" 

Write-Output "Full URL Request: $FullUrl"

$Response = Invoke-WebRequest -Uri $FullUrl -Method GET

Write-Output $Response




