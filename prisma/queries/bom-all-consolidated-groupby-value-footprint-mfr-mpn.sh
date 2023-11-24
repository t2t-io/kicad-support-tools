#!/bin/bash
#

[ "" == "${MILESTONE}" ] && MILESTONE="default"

cat <<__EOF__
SELECT
	ROW_NUMBER() OVER() AS id,
	GROUP_CONCAT(refs, " ") AS refs, 
	SUM(qty) AS qty, 
	value, 
	footprint, 
	datasheet, 
	mfr, 
	mpn, 
	furnished_by,
	MAX(digikey) as digikey,
	MAX(lcsc) as lcsc,
	mouser,
	octopart,
	spec,
	CASE
		WHEN furnished_by = '--' THEN 'Yes'
		WHEN furnished_by = 'T2T' THEN ''
		WHEN furnished_by = 'EMS' THEN ''
		ELSE '??'
	END AS dnf
FROM Symbol_Filtered_Grouped_Consolidated
GROUP BY value, footprint, datasheet, mfr, mpn, furnished_by
ORDER BY value, footprint, datasheet, mfr, mpn, furnished_by;
__EOF__
