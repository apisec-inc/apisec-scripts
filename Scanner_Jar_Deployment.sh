#!/bin/bash
# Begin
#
# Syntax: bash Scanner_Jar_Deployment.sh --fx-host "<Hostname or IP>" --fx-iam "<FX_IAM>" ---fx-key "FX_KEY"   

# Example usage: bash Scanner_Jar_Deployment.sh --fx-host "https://cloud.apisec.ai" --fx-iam "xFDt+LOZeTIccnHw1XHxJ1Gzhr4gUg2y" ---fx-key "I0YV0i/1jXNy/EEeTt5KMm/rwgZgRWgNuGmqADnGIqSwMXCvDrBtSlYbEQASNtYo"   

TEMP=$(getopt -n "$0" -a -l "fx-host:,fx-iam:,fx-key:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		    --fx-host) FX_HOST="$2"; shift;;
                    --fx-iam) FX_IAM="$2"; shift;;
                    --fx-key) FX_KEY="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done

curl -s -O https://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@raw.githubusercontent.com/apisec-inc/Release/main/Scanner/bot.jar

export FX_HOST="$FX_HOST"
export FX_IAM="$FX_IAM"
export FX_KEY="$FX_KEY"

java -jar bot.jar

# End

