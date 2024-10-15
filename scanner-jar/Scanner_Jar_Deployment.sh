#!/bin/bash
# Begin
#
# Syntax: bash Scanner_Jar_Deployment.sh --fx-host "<Hostname or IP>" --fx-iam "<FX_IAM>" --fx-key "FX_KEY" --github-access-token "<GITHUB_ACCESS_TOKEN>"

# Example usage: bash Scanner_Jar_Deployment.sh --fx-host "https://cloud.apisec.ai" --fx-iam "xFDt+LOZeTIccnHw1XHxJ1Gzhr4gUg2y" --fx-key "I0YV0i/1jXNy/EEeTt5KMm/rwgZgRWgNuGmqADnGIqSwMXCvDrBtSlYbEQASNtYo" --github-access-token "ghp_GJwqwerfdgsdfrwewsfsfghrtyrukiuoykhjk"

TEMP=$(getopt -n "$0" -a -l "fx-host:,fx-iam:,fx-key:,github-access-token:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		    --fx-host) FX_HOST="$2"; shift;;
                    --fx-iam) FX_IAM="$2"; shift;;
                    --fx-key) FX_KEY="$2"; shift;;
                    --github-access-token) GITHUB_ACCESS_TOKEN="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done

#curl -s -O https://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@raw.githubusercontent.com/apisec-inc/Release/main/Scanner/bot.jar
#curl -s -O https://$GITHUB_ACCESS_TOKEN@raw.githubusercontent.com/apisec-inc/Release/main/Scanner/bot.jar
wget https://github.com/apisec-inc/apisec-scripts/raw/refs/heads/master/scanner-jar/bot.jar

export FX_HOST="$FX_HOST"
export FX_IAM="$FX_IAM"
export FX_KEY="$FX_KEY"
export SPRING_AMQP_DESERIALIZATION_TRUST_ALL="true"

java -jar bot.jar

# End

