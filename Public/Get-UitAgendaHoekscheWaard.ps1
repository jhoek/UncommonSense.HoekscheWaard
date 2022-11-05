Invoke-WebRequest -Uri 'https://widget.visithw.nl/?type=event&sort=calendar&order=asc'
| Select-Object -ExpandProperty Links
| Select-Object -ExpandProperty HRef
| Where-Object { $_ -Like 'https://www.visithw.nl/nl/uitagenda/*' }
| ForEach-Object {
    $Content = Invoke-WebRequest -Uri $_ | Select-Object -ExpandProperty Content
    $Description = ($Content | pup '.item-details__long-description text{}' --plain | ForEach-Object { $_.Trim() } | Where-Object { $_ }) -join ' '

    $Content
    | pup 'script[type] text{}' --plain
    | ConvertFrom-Json
    | ForEach-Object {
        [PSCustomObject]@{
            StartDate   = $_.StartDate
            EndDate     = $_.EndDate
            Title       = $_.Name
            Description = $Description
            Image       = $_.Image
            Location    = (@($_.Location.Name, $_.Location.Address.StreetAddress, $_.Location.Address.PostalCode, $_.Location.Address.AddressLocality) | Where-Object { $_ } ) -join ', '
            PhoneNo     = $_.location.telephone
            Latitude    = $_.location.geo.Latitude
            Longitude   = $_.location.geo.Longitude
        }
    }
}
| Sort-Object -Property StartDate