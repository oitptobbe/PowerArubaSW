#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Write-ArubaSWCliBatch {

    <#
        .SYNOPSIS
        Write a cli batch command.

        .DESCRIPTION
        Write a cli batch command on Aruba OS Switch.
        All configuration commands in non-interactive mode  are supported. Exit, configure, erase, startup-config commands are supported.
        Crypto, show, execution and testmode commands are NOT supported.

        .EXAMPLE
        Write-ArubaSWCliBatch -command 
        Write a cli batch command on the switch.
    #>

    Param(
        [Parameter (Mandatory=$true)]
        [string[]]$command
    )

    Begin {
    }

    Process {

        $nb = 0

        foreach ($line in $command)
        {
            $result = $result + $command[$nb] + "`n"
            $nb = $nb + 1
        }
        
        [string]$result

        $url = "rest/v4/cli_batch"

        $conf = new-Object -TypeName PSObject

        $encode = [System.Text.Encoding]::UTF8.GetBytes($result)

        $EncodedText =[Convert]::ToBase64String($encode)

        $conf | add-member -name "cli_batch_base64_encoded" -membertype NoteProperty -Value $EncodedText

        $response = invoke-ArubaSWWebRequest -method "POST" -body $conf -url $url

        $run = $response | convertfrom-json

        $run
    }

    End {
    }
}

function Get-ArubaSWCliBatchStatus {

    <#
        .SYNOPSIS
        Get a cli batch command status.

        .DESCRIPTION
        Get a cli batch command status on Aruba OS Switch.

        .EXAMPLE
        Get-ArubaSWCliBatchStatus 
        Get a cli batch command status on the switch.
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/cli_batch/status"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | convertfrom-json).cmd_exec_logs

        $run
    }

    End {
    }
}