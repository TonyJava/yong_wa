#!/bin/sh

CMD="bundle exec rake secret"

# run () {
#   if [ "$(id -un)" = "$AS_USER" ]; then
#     eval $1
#   else
#     su -c "$1" - $AS_USER
#   fi
# }

if [ $SECRET_KEY_BASE ]; then
  echo "scret key for production is existed."
else
  echo "create scret key for production."
  key=`$CMD`
  echo "export SECRET_KEY_BASE=$key" >> /etc/profile
fi