#!/bin/bash
#

#
# Depends on create-views.sh
#
cat <<__EOF__
SELECT * FROM Symbol_Filtered_Grouped;
__EOF__
