#!/usr/bin/env bash

echo "Start dispatcher"
#apachectl start
/sbin/apachectl -D FOREGROUND &
if [ "$#" -ne 0 ] ; then
  "$@"
else
  su genero -c "/opt/fourjs/gas/bin/fastcgidispatch -s -E res.log.categories_filter=ALL"
fi
echo "DONE"
