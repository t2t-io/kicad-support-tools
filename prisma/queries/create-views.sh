#!/bin/bash
#

[ "" == "${MILESTONE}" ] && MILESTONE="default"

cat <<__EOF__
DROP VIEW IF EXISTS Symbol_Filtered;
DROP VIEW IF EXISTS Symbol_Filtered_Grouped;
DROP VIEW IF EXISTS Symbol_Filtered_Grouped_Consolidated;

CREATE VIEW Symbol_Filtered
AS
	SELECT *
	FROM Symbol
	WHERE
		design = '${MILESTONE}' AND
		footprint NOT LIKE 'TestPoint%' AND 
		footprint NOT LIKE 'Mount%Hole%' AND 
		footprint NOT LIKE 'SolderJumper%'
	ORDER BY board, designator, rid;


CREATE VIEW Symbol_Filtered_Grouped
AS
	SELECT
		design,
		board,
		GROUP_CONCAT(reference, ',') AS refs, 
		COUNT(*) AS qty, 
		value, 
		footprint, 
		mfr, 
		mpn, 
		furnished_by,
		datasheet,
		designator,
		MAX(octopart) AS octopart,
		MAX(digikey) AS digikey,
		MAX(mouser) AS mouser,
		MAX(lcsc) AS lcsc,
		MAX(spec) AS spec
	FROM 
		Symbol_Filtered
	GROUP BY board, value, footprint, mfr, mpn, datasheet, designator, furnished_by
	ORDER BY board, refs, value, footprint, mfr, mpn, datasheet, designator, furnished_by;


CREATE VIEW Symbol_Filtered_Grouped_Consolidated
AS
	SELECT 
		board || ":" || refs AS refs, 
		qty, 
		value, 
		mfr, 
		mpn, 
		datasheet, 
		footprint, 
		furnished_by, 
		octopart, 
		digikey, 
		mouser, 
		lcsc, 
		spec 
	FROM Symbol_Filtered_Grouped;
__EOF__
