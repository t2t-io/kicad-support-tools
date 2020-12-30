
ifndef BOM_SHEET
$(error BOM_SHEET is not set)
endif

ifndef BOM_GROUPED_SHEET
$(error BOM_GROUPED_SHEET is not set)
endif

ifndef BOM_CONSOLIDATED_SHEET
$(error BOM_CONSOLIDATED_SHEET is not set)
endif

ifndef PART_DIR
$(error PART_DIR is not set)
endif

ifeq ($(USE_RESERVED_FIELDS),true)
EXTRA_FIELDS := , reserved1, reserved2, reserved3
endif

BOM_FOR_OCTOPART_SHEET := $(PART_DIR)/_octopart.tsv
BOM_FOR_OCTOPART_PROCUREMENT_SHEET := $(PART_DIR)/_octopart_procurement.tsv
BOM_FOR_CHECK1 := $(PART_DIR)/_check1.tsv

ALL_SHEETS := $(BOM_GROUPED_SHEET) $(BOM_CONSOLIDATED_SHEET) $(BOM_FOR_OCTOPART_SHEET) $(BOM_FOR_OCTOPART_PROCUREMENT_SHEET)

ifeq ($(GENERATE_CHECKING_SHEETS),true)
ALL_SHEETS += $(BOM_FOR_CHECK1)
endif

all: $(ALL_SHEETS)

checkout: $(BOM_ALL_CHECKOUT_SHEET)

clean:
	rm -vf $(ALL_SHEETS)

$(BOM_GROUPED_SHEET): $(BOM_SHEET)
	echo "processing $(notdir $<) to generate $(notdir $@) ..."
	cat $< | q -t -H -O "SELECT board, GROUP_CONCAT(refs, ',') AS refs, COUNT(*) AS qty, value, footprint, mfr, mpn, furnished_by, datasheet, designator$(EXTRA_FIELDS) FROM - GROUP BY board, value, footprint, mfr, mpn, furnished_by, datasheet, designator ORDER BY board, refs, value, footprint, mfr, mpn, furnished_by, datasheet, designator$(EXTRA_FIELDS)" > $@
	cat $@ | q -t -H -O --output-delimiter=, 'SELECT * FROM - ' > $@.csv
	cat $@ | csvlook -t | awk '{printf "\t%s\n", $$0}'
	echo ""

$(BOM_CONSOLIDATED_SHEET): $(BOM_GROUPED_SHEET)
	echo "processing $(notdir $<) to generate $(notdir $@) ..."
ifeq ($(MULTIPLE_BOARDS),true)
	cat $< \
		| q -t -H -O 'SELECT * FROM - WHERE furnished_by IN ("T2T", "EMS")' \
		| q -t -H -O 'SELECT board || ":" || refs AS refs, qty, value, mfr, mpn, datasheet, footprint, furnished_by, designator$(EXTRA_FIELDS) FROM -' \
		| q -t -H -O 'SELECT GROUP_CONCAT(refs, " ") AS refs, SUM(qty) AS qty, value, footprint, mfr, mpn, furnished_by, datasheet, designator$(EXTRA_FIELDS) FROM - GROUP BY value, footprint, mfr, mpn, furnished_by, datasheet, designator$(EXTRA_FIELDS) ORDER BY value, footprint, mfr, mpn, furnished_by, datasheet, designator$(EXTRA_FIELDS)' \
		> $@
else
	cat $< \
		| q -t -H -O 'SELECT * FROM - WHERE furnished_by NOT IN ["T2T", "EMS"]' \
		| q -t -H -O 'SELECT refs, qty, value, mfr, mpn, datasheet, footprint, furnished_by, designator, rid$(EXTRA_FIELDS) FROM -' > $@
endif
	cat $@ | q -t -H -O --output-delimiter=, 'SELECT * FROM - ' > $@.csv
	cat $@ | csvlook -t | awk '{printf "\t%s\n", $$0}'
	echo ""

$(BOM_FOR_OCTOPART_SHEET): $(BOM_CONSOLIDATED_SHEET)
	echo "processing $(notdir $<) to generate $(notdir $@) ..."
	cat $< | q -t -H -O "SELECT qty AS Qty, mpn AS MPN, mfr AS Manufacturer, refs AS 'Schematic Reference', value AS 'Internal Part Number', designator || ' (' || mfr || ')' AS 'Description' FROM - GROUP BY designator, mpn ORDER BY designator, mpn" > $@
	echo "processing $(notdir $<) to generate $(notdir $@).csv ..."
	cat $@ | q -t -H -O --output-delimiter=, 'SELECT * FROM - ' > $@.csv
	cat $@ | csvlook -t | awk '{printf "\t%s\n", $$0}'
	echo ""

$(BOM_FOR_OCTOPART_PROCUREMENT_SHEET): $(BOM_CONSOLIDATED_SHEET)
	echo "processing $(notdir $<) to generate $(notdir $@) ..."
	cat $< | q -t -H -O "SELECT qty AS Qty, mpn AS MPN, mfr AS Manufacturer, refs AS 'Schematic Reference', value AS 'Internal Part Number', designator || ' (' || mfr || ')' AS 'Description' FROM - WHERE furnished_by = 'T2T' GROUP BY designator, mpn ORDER BY designator, mpn" > $@
	echo "processing $(notdir $<) to generate $(notdir $@).csv ..."
	cat $@ | q -t -H -O --output-delimiter=, 'SELECT * FROM - ' > $@.csv
	echo ""

$(BOM_FOR_CHECK1): $(BOM_SHEET)
	echo "processing $(notdir $<) to generate $(notdir $@) ..."
	cat $< \
		| q -t -H -O 'SELECT * FROM - WHERE furnished_by IN ("T2T", "EMS")' \
		| q -t -H -O "SELECT board, GROUP_CONCAT(refs, ',') AS refs, COUNT(*) AS qty, value, footprint, mfr, mpn, furnished_by, datasheet$(EXTRA_FIELDS) FROM - GROUP BY board, value, footprint, mfr, mpn, furnished_by, datasheet ORDER BY board, refs, value, footprint, mfr, mpn, furnished_by, datasheet$(EXTRA_FIELDS)" \
		| q -t -H -O 'SELECT board || ":" || refs AS refs, qty, value, mfr, mpn, datasheet, footprint, furnished_by$(EXTRA_FIELDS) FROM -' \
		| q -t -H -O 'SELECT GROUP_CONCAT(refs, " ") AS refs, SUM(qty) AS qty, value, footprint, mfr, mpn, furnished_by, datasheet$(EXTRA_FIELDS) FROM - GROUP BY value, footprint, mfr, mpn, furnished_by, datasheet$(EXTRA_FIELDS) ORDER BY value, footprint, mfr, mpn, furnished_by, datasheet$(EXTRA_FIELDS)' \
		> $@
	cat $@ | q -t -H -O --output-delimiter=, 'SELECT * FROM - ' > $@.csv
	#cat $@ | csvlook -t | awk '{printf "\t%s\n", $$0}'
	echo ""
