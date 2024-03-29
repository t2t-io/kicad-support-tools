#!/bin/bash
#

[ "" == "${MILESTONE}" ] && MILESTONE="default"
[ "" == "${BOARD}" ] && BOARD="MB"

cat <<__EOF__
SELECT
	GROUP_CONCAT(reference, ',') AS refs,
	COUNT(*) AS qty,
	value,
	footprint,
	datasheet,
	mfr,
	mpn,
	furnished_by,
	digikey,
	lcsc,
	spec
FROM 
	(SELECT * FROM Symbol ORDER BY design, board, designator, rid)
WHERE
	design = '${MILESTONE}' AND
	board = '${BOARD}' AND
	footprint NOT LIKE 'TestPoint%' AND 
	footprint NOT LIKE 'Mount%Hole%' AND 
	footprint NOT LIKE 'SolderJumper%'
GROUP BY value, footprint, datasheet, mfr, mpn, furnished_by
ORDER BY designator, rid, value, footprint, datasheet, mfr, mpn, furnished_by
__EOF__
