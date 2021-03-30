#!/bin/sh
set -e

GITHUB_USER="senabi"
BRANCH="main"

rm -f info.sh 
rm -f part-1.sh 
rm -f part-2.sh
rm -f variables.sh

curl -O https://raw.githubusercontent.com/$GITHUB_USER/auto/$BRANCH/info.sh 
curl -O https://raw.githubusercontent.com/$GITHUB_USER/auto/$BRANCH/part-1.sh 
curl -O https://raw.githubusercontent.com/$GITHUB_USER/auto/$BRANCH/part-2.sh
curl -O https://raw.githubusercontent.com/$GITHUB_USER/auto/$BRANCH/variables.sh

chmod +x info.sh 
chmod +x part-1.sh 
chmod +x part-2.sh
chmod +x variables.sh
