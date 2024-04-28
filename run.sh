#/bin/sh
echo "Please enter telegram token:"
read -s TELE_TOKEN 
export TELE_TOKEN
./kbot start
