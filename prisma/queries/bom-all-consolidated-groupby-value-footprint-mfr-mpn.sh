#!/bin/bash
#

[ "" == "${MILESTONE}" ] && MILESTONE="default"

cat <<__EOF__
SELECT
	GROUP_CONCAT(refs, " ") AS refs, 
	SUM(qty) AS qty, 
	value, 
	footprint, 
	mfr, 
	mpn, 
	MAX(digikey) as digikey,
	MAX(lcsc) as lcsc,
	datasheet, 
	CASE
		WHEN furnished_by = '--' THEN 'Yes'
		WHEN furnished_by = 'T2T' THEN ''
		WHEN furnished_by = 'EMS' THEN ''
		ELSE '??'
	END AS dnf,
	furnished_by
FROM Symbol_Filtered_Grouped_Consolidated
GROUP BY value, footprint, mfr, mpn, datasheet, furnished_by
ORDER BY value, footprint, mfr, mpn, datasheet, furnished_by;
__EOF__
