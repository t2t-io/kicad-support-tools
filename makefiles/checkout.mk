MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:


ifndef BOM_CONSOLIDATED_SHEET
$(error BOM_CONSOLIDATED_SHEET is not set)
endif

ifndef CHECKOUT_DIR
$(error CHECKOUT_DIR is not set)
endif

ifndef TARGET_SETS
TARGET_SETS := 10
endif

ifndef TARGET_BATCH
TARGET_BATCH := A
endif

ifndef TARGET_BAG_DIGITS
TARGET_BAG_DIGITS := 3
endif

BOM_CHECKOUT_SHEET := $(CHECKOUT_DIR)/checkout.tsv

ALL_SHEETS = $(BOM_CHECKOUT_SHEET)

all: $(ALL_SHEETS)


$(BOM_CHECKOUT_SHEET): $(BOM_CONSOLIDATED_SHEET)
	cat $< | csvlook -t | awk '{printf "\t%s\n", $$0}'
	echo "processing $(notdir $<) to generate $(notdir $@) ..."
	mkdir -p $(notdir $@)
	cat $< \
		| q -t -H -O -W all "SELECT ROW_NUMBER() OVER(ORDER BY refs) AS id, refs, value, mfr, mpn, footprint, furnished_by, qty, qty*$(TARGET_SETS) as target_qty_$(TARGET_SETS) FROM - WHERE furnished_by = 'T2T' GROUP BY value, mfr, mpn, footprint" \
		> $@
	cat $@ | q -t -H -O --output-delimiter=, 'SELECT * FROM - ' > $@.csv
	cat $@ | csvlook -t | awk '{printf "\t%s\n", $$0}'
	echo ""

#		| q -t -H -O -W all "SELECT printf('$(TARGET_BATCH)%0$(TARGET_BAG_DIGITS)d', id) AS bag, * FROM -" \
