#!/bin/bash
#

#
# Depends on create-views.sh
#
cat <<__EOF__
SELECT
	design,
	board,
	reference,
	value,
	footprint,
	datasheet,
	furnished_by,
	mfr,
	mpn,
	octopart,
	spec,
	digikey,
	lcsc,
	lcsc_link,
	mouser
FROM 
Symbol_Filtered;
__EOF__
