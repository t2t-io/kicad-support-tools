
ifndef BOM_SHEET
$(error BOM_SHEET is not set)
endif

ifndef PART_DIR
$(error PART_DIR is not set)
endif

BOM_ALL_GROUPED_SHEET := $(PART_DIR)/_all_grouped.tsv
BOM_ALL_NO_BOARD_SHEET := $(PART_DIR)/_all_no_boards.tsv
BOM_FOR_OCTOPART_SHEET := $(PART_DIR)/_all_octopart.tsv

ifeq ($(MULTIPLE_BOARDS),true)
BOM_BASE_SHEET_FOR_OCTOPART := $(BOM_ALL_NO_BOARD_SHEET)
else
BOM_BASE_SHEET_FOR_OCTOPART := $(BOM_SHEET)
endif


BOM_SHEETS := $(BOM_ALL_GROUPED_SHEET) $(BOM_FOR_OCTOPART_SHEET)


#	export PROCUREMENT_LIST="${TOP}/parts/_procurement.csv"
#	export PROCUREMENT_LIST_MD="${TOP}/parts/_procurement.csv.md"
#	export PROCUREMENT_OCTOPART_LIST="${TOP}/parts/_procurement_octopart_bom.csv"
#	export PROCUREMENT_OCTOPART_V2_LIST="${TOP}/parts/_procurement_octopart_bom_v2.csv"

all: $(BOM_SHEETS)


$(BOM_ALL_GROUPED_SHEET): $(BOM_SHEET)
	echo "processing $(notdir $<) to generate $(notdir $@) ..."
	cat $< | q -t -H -O "SELECT board, GROUP_CONCAT(refs, ',') as refs, COUNT(*) as qty, value, footprint, mfr, mpn, furnished_by FROM - GROUP BY board, value, footprint, mfr, mpn, furnished_by ORDER BY board, refs, value, footprint, mfr, mpn, furnished_by" > $@
	cat $@ | csvlook -t | awk '{printf "\t%s\n", $$0}'
	echo ""

$(BOM_ALL_NO_BOARD_SHEET): $(BOM_SHEET)
	echo "processing $(notdir $<) to generate $(notdir $@) ..."
	cat $< | q -t -H -O 'SELECT board || ":" || refs as refs, value, mfr, mpn, datasheet, footprint, furnished_by, designator, rid FROM -' > $@
	cat $@ | csvlook -t | awk '{printf "\t%s\n", $$0}'
	echo ""

$(BOM_FOR_OCTOPART_SHEET): $(BOM_BASE_SHEET_FOR_OCTOPART)
	echo "processing $(notdir $<) to generate $(notdir $@) ..."
	cat $< | q -t -H -O "SELECT COUNT(*) AS Qty, mpn AS MPN, mfr AS Manufacturer, GROUP_CONCAT(refs, ', ') AS 'Schematic Reference', value AS 'Internal Part Number', designator || ' (' || mfr || ')' AS 'Description' FROM - GROUP BY designator, mpn ORDER BY designator, mpn" > $@
	cat $< | q -t -H -O --output-delimiter=, "SELECT COUNT(*) AS Qty, mpn AS MPN, mfr AS Manufacturer, GROUP_CONCAT(refs, ', ') AS 'Schematic Reference', value AS 'Internal Part Number', designator || ' (' || mfr || ')' AS 'Description' FROM - GROUP BY designator, mpn ORDER BY designator, mpn" > $@.csv
	cat $@ | csvlook -t | awk '{printf "\t%s\n", $$0}'
	echo ""
