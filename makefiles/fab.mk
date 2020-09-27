MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:


ifndef BOM_SHEET
$(error BOM_SHEET is not set)
endif

ifndef FAB_DIR
$(error FAB_DIR is not set)
endif

ifndef BOARDS
$(error BOARDS is not set)
endif

COMMA := ,

FAB_SHEET	:= $(FAB_DIR)/_all_boards.tsv
ALL_SHEETS	:= $(addprefix $(FAB_DIR)/boards/,$(subst $(COMMA), ,$(BOARDS)))
ALL_SHEETS	:= $(addsuffix /bom.csv,$(ALL_SHEETS))


all: $(ALL_SHEETS)
	# echo $(FAB_DIR)
	# echo $(BOARDS)
	# echo $(ALL_SHEETS)


$(FAB_SHEET): $(BOM_SHEET)
	echo "generating $(notdir $@) ..."
	cat $< | q -H -O -t 'SELECT * FROM - ORDER BY board,designator,rid' > $@

%.csv: $(FAB_SHEET)
	echo "generating $(notdir $(patsubst %/,%,$(dir $@)))/$(notdir $@) ..."
	echo $(notdir $(patsubst %/,%,$(dir $@)))
	echo "SELECT GROUP_CONCAT(refs,',') as refs, COUNT(refs) as qty, value, mfr, mpn, datasheet, footprint, furnished_by FROM - WHERE board = '$(notdir $(patsubst %/,%,$(dir $@)))' GROUP BY value, mfr, mpn, datasheet, footprint, furnished_by ORDER BY furnished_by,designator,rid"
	cat $< | q -H -O -t -D ',' "SELECT GROUP_CONCAT(refs,',') as refs, COUNT(refs) as qty, value, mfr, mpn, datasheet, footprint, furnished_by FROM - WHERE board = '$(notdir $(patsubst %/,%,$(dir $@)))' GROUP BY value, mfr, mpn, datasheet, footprint, furnished_by ORDER BY furnished_by,designator,rid" > $@
