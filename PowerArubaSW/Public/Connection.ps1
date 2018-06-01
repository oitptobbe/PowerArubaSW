
#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Connect-ArubaSW {

  <#
      .SYNOPSIS
      Connect to a ArubaOS Switches (Provision)

      .DESCRIPTION
      Connect to a ArubaOS Switches
      Actually only support to use HTTP

      .EXAMPLE
      Connect-ArubaSW -Server 192.0.2.1 -Username manager -Password aruba

      Connect to a ArubaOS Switch with IP 192.0.2.1

  #>

    Param(
        [Parameter(Mandatory = $true)]
        [String]$Server,
        [Parameter(Mandatory = $false)]
        [String]$Username,
        [Parameter(Mandatory = $false)]
        [String]$Password
    )

    Begin {
    }

    Process {

        $connection = @{server="";session="";cookie=""}

        $postParams = @{userName=$Username;password=$Password}
        $url = "http://${Server}:80/rest/v3/login-sessions"
        try {
            $response = Invoke-WebRequest $url -Method POST -Body ($postParams | Convertto-Json ) -SessionVariable arubasw
        }
        catch {
            #$_
            throw "Unable to connect"
        }
        $cookie = ($response.content | ConvertFrom-Json).cookie
        $smallcookie = $cookie.split("=")[1]
        $arubasw.Cookies.Add((Set-Cookie -name "sessionId" -value $smallcookie -domain $server));

        $connection.server = $server
        $connection.cookie = $cookie
        $connection.session = $arubasw

        set-variable -name DefaultArubaSWConnection -value $connection -scope Global

    }

    End {
    }
}

function Disconnect-ArubaSW {

    <#
        .SYNOPSIS
        Disconnect to a ArubaOS Switches (Provision)

        .DESCRIPTION
        Disconnect the connection on ArubaOS Switchs

        .EXAMPLE
        Disconnect-ArubaSW

        Disconnect the connection

        .EXAMPLE
        Disconnect-ArubaSW -noconfirm

        Disconnect the connection with no confirmation

    #>

    Param(
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm
    )

    Begin {
    }

    Process {

        $url = "rest/v1/login-sessions"

        if ( -not ( $Noconfirm )) {
            $message  = "Remove Aruba Switch connection."
            $question = "Proceed with removal of Aruba Switch connection ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove Aruba SW connection"
            $null = invoke-ArubaSWWebRequest -method "DELETE" -url $url
            write-progress -activity "Remove Aruba SW connection" -completed
            if (Get-Variable -Name DefaultArubaSWConnection -scope global ) {
                Remove-Variable -name DefaultArubaSWConnection -scope global
            }
        }

    }

    End {
    }
}