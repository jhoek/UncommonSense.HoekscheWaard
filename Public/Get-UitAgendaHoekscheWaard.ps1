function Get-UitAgendaHoekscheWaard
{
    param
    (
    )

    Invoke-WebRequest -Uri 'https://widget.visithw.nl/?type=event&sort=calendar&order=asc'
    | Select-Object -ExpandProperty Links
    | Select-Object -ExpandProperty HRef
    | Where-Object { $_ -Like 'https://www.visithw.nl/nl/uitagenda/*' }
    | ForEach-Object {
        $Document = ConvertTo-HtmlDocument -Uri $_
        $Description = $Document | Select-HtmlNode -CssSelector '.item-details__long-description' | Get-HtmlNodeText

        $Document
        | Select-HtmlNode -CssSelector 'script[type]'
        | Get-HtmlNodeText
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
}