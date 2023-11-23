#!/bin/bash
#

[ "" == "${MILESTONE}" ] && MILESTONE="default"
[ "" == "${BOARD}" ] && BOARD="MB"

cat <<__EOF__
SELECT
	GROUP_CONCAT(reference, ',') AS refs,
	COUNT(*) AS qty,
	furnished_by,
	value,
	footprint,
	mfr,
	mpn
FROM 
	(SELECT * FROM Symbol ORDER BY design, board, designator, rid)
WHERE
	design = '${MILESTONE}' AND
	board = '${BOARD}'
GROUP BY 
	furnished_by, value, footprint, mfr, mpn
ORDER BY 
	designator, rid, value, footprint, furnished_by
__EOF__
