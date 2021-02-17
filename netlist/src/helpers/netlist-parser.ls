require! <[debug]>
DBG = debug 'netlist'
INFO = console.log
SExpr = require \js-sexpr

const SE_OBJECT_TYPE_BASE = \base
const SE_OBJECT_TYPE_NULL = \null
const SE_OBJECT_TYPE_SYMBOL = \symbol
const SE_OBJECT_TYPE_STRING = \string
const SE_OBJECT_TYPE_LIST = \list
const SE_OBJECT_TYPE_EMPTYLIST = \emptylist


class SE_BaseObject
  (@value, @type=SE_OBJECT_TYPE_BASE) ->
    return

  to_json: (simplified=no) -> 
    return null


class SE_NullObject extends SE_BaseObject
  ->
    super null, SE_OBJECT_TYPE_NULL

  to_json: (simplified=no) ->
    return null


RETURN_WITH_WARNING = (ret, message) ->
  DBG message
  return ret

RETURN_NULL_WITH_WARNING = (message) ->
  DBG message
  return new SE_NullObject!


class SE_Symbol extends SE_BaseObject
  (@value) ->
    super value, SE_OBJECT_TYPE_SYMBOL

  to_json: (simplified=no) -> 
    return @value


class SE_String extends SE_BaseObject
  (@value) ->
    super value, SE_OBJECT_TYPE_STRING

  to_json: (simplified=no) -> 
    return @value if simplified
    return "\"#{@value}\""


class SE_EmptyList extends SE_BaseObject
  (@value=[]) ->
    super value, SE_OBJECT_TYPE_EMPTYLIST

  to_json: (simplified=no) -> 
    return []


class SE_List extends SE_BaseObject
  (@value, @symbol, @manager, @lv=0) ->
    super value, SE_OBJECT_TYPE_LIST
    self = @
    self.name = self.symbol.value
    self.length = value.length
    self.list = [ (self.parse_element v) for v in value ]
    self.dictionary = { [l.symbol.value, l.list] for l in self.list when l.type is SE_OBJECT_TYPE_LIST }
    /*
    self.dictionary = {}
    for l in self.list
      if l.type is SE_OBJECT_TYPE_LIST
        if self.manager.auto_list_to_kv
          if l.list.length is 1 and l.list[0].type is SE_OBJECT_TYPE_STRING
            self.dictionary[l.symbol.value] = l.list[0].to_json yes
          else
            self.dictionary[l.symbol.value] = l.list
        else
          self.dictionary[l.symbol.value] = l.list
    */
  
  parse_element: (x) ->
    return @manager.parse_list x, @lv if Array.isArray x
    return @manager.parse_string x if SE_OBJECT_TYPE_STRING is typeof x
    return RETURN_NULL_WITH_WARNING "unexpected type when parsing the element of list: #{typeof x} => #{JSON.stringify x}"

  to_json: (simplified=no) -> 
    return @list


const NL_COMP_PROPERTY_NAME_ALIASES = {
  "Furnished by": "furnished_by"
  "Mfr."        : "mfr"
  "Mfr. PN"     : "mpn"
}


/**
 * Parse following structure to get each predefined fields and extra fields: 
 *
 Example in Main sheet:

    (comp (ref "BT1")
      (value "BR1632")
      (footprint "mFootPrintLibrary:SMTM1632")
      (datasheet "https://www.mouser.com/datasheet/2/346/3.9228.4-2_SMTM1632-258033.pdf")
      (fields
        (field (name "Furnished by") "T2T")
        (field (name "Mfr.") "Renata")
        (field (name "Mfr. PN") "SMTM1632"))
      (libsource (lib "Device") (part "Battery_Cell") (description "Single-cell battery"))
      (property (name "Furnished by") (value "T2T"))
      (property (name "Mfr. PN") (value "SMTM1632"))
      (property (name "Mfr.") (value "Renata"))
      (property (name "Sheetname") (value ""))
      (property (name "Sheetfile") (value "/Users/yagamy/Works/workspaces/achb/gitea/urochecker-ee-design/external/UroChecker_HW/UroChecker/MainBoard/MainBoard.sch"))
      (sheetpath (names "/") (tstamps "/"))
      (tstamp "00000000-0000-0000-0000-0000605d8a27"))

  Example in subsheet:

    (comp (ref "C74")
      (value "10nF/25V/0402/10%")
      (footprint "Capacitor_SMD:C_0402_1005Metric")
      (datasheet "https://www.mouser.tw/datasheet/2/40/X7RDielectric-777024.pdf")
      (fields
        (field (name "Furnished by") "T2T")
        (field (name "Mfr.") "AVX")
        (field (name "Mfr. PN") "04023C103KAT2A"))
      (libsource (lib "Device") (part "C_Small") (description "Unpolarized capacitor, small symbol"))
      (property (name "Furnished by") (value "T2T"))
      (property (name "Mfr. PN") (value "04023C103KAT2A"))
      (property (name "Mfr.") (value "AVX"))
      (property (name "Sheetname") (value "NFC_Mod"))
      (property (name "Sheetfile") (value "NFC_Mod.sch"))
      (sheetpath (names "/NFC_Mod/") (tstamps "/00000000-0000-0000-0000-00006a66cee5/"))
      (tstamp "00000000-0000-0000-0000-00005e2047d7"))
 *
 *
 */
class NL_Component
  (@parser, @slist, @id=0) ->
    self = @
    self.attributes = {}    # default attributes: ref, value, footprint, sheetpath, datasheet, and tstamp
    self.attributes['id'] = id
    self.attributes['ref'] = ref = slist.dictionary['ref'][0].to_json yes
    self.attributes['value'] = slist.dictionary['value'][0].to_json yes
    self.attributes['footprint'] = slist.dictionary['footprint'][0].to_json yes
    self.attributes['sheetpath'] = slist.dictionary['sheetpath'][0].list[0].to_json yes
    self.attributes['datasheet'] = slist.dictionary['datasheet'][0].to_json yes if slist.dictionary['datasheet']?
    self.attributes['tstamp'] = slist.dictionary['tstamp'][0].to_json yes
    self.properties = {}
    [ (self.parse_property l) for l in slist.list ]
    self.parse_ref ref
    return

  parse_ref: (ref) ->
    {attributes} = self = @
    re0 = /^[A-Za-z]+[0-9]+$/
    re1 = /^[A-Za-z]+/
    re2 = /[0-9]+$/
    if re0.test ref
      designator = (re1.exec ref)[0]
      rid = (re2.exec ref)[0]
      rid = parseInt rid
      attributes['designator'] = designator
      attributes['rid'] = rid
    else
      attributes['designator'] = '#'
      attributes['rid'] = -1

  parse_property: (p) ->
    return unless p.type is SE_OBJECT_TYPE_LIST
    return unless p.symbol.value is \property
    return unless p.length is 2
    return unless p.list[0].type is SE_OBJECT_TYPE_LIST
    return unless p.list[1].type is SE_OBJECT_TYPE_LIST
    return unless p.list[0].symbol.value is \name
    return unless p.list[1].symbol.value is \value
    return unless p.list[0].list.length is 1
    return unless p.list[1].list.length is 1
    return unless p.list[0].list[0].type is SE_OBJECT_TYPE_STRING
    return unless p.list[1].list[0].type is SE_OBJECT_TYPE_STRING
    name = p.list[0].list[0].to_json yes
    value = p.list[1].list[0].to_json yes
    alias = NL_COMP_PROPERTY_NAME_ALIASES[name]
    name = alias if alias?
    @properties[name] = value

  get_field: (name) ->
    {attributes, properties} = self = @
    v = attributes[name]
    v = properties[name] unless v?
    return v

  get_fields: (field_names=[]) ->
    self = @
    xs = [ (self.get_field n) for n in field_names ]
    return xs

  to_csv: (delimiter=' ') ->
    {ref, value, footprint, tstamp} = self = @
    xs = [ref, value, footprint, tstamp]
    return xs.join delimiter



class NetlistParser
  (@configs, text) ->
    self = @
    self.se = new SExpr!
    DBG "s-expression parsing begins ... (#{text.length} bytes)"
    self.json = self.se.parse text
    DBG "s-expression parsing end, then parse tree"
    self.root = self.parse_list self.json
    DBG "root.symbol.value => #{self.root.symbol.value}" if self.root?
    xs = self.root.dictionary['components']
    @components = [ (new NL_Component self, x, i) for let x, i in xs ]

  parse_string: (str) ->
    [q0, ...middle, q1] = str
    return new SE_Symbol str if (q0 is not \") and (q1 is not \")
    return new SE_String (middle.join '') if q0 is \" and q1 is \"
    return RETURN_NULL_WITH_WARNING "unmatched quoted string: #{str}"

  parse_list: (list, lv=0) ->
    return RETURN_NULL_WITH_WARNING "list is empty" unless list?
    return RETURN_NULL_WITH_WARNING "list is not an Array object" unless Array.isArray list
    return new SE_EmptyList! if list.length is 0
    [first, ...tail] = list
    return RETURN_NULL_WITH_WARNING "expect a string as first element of list, but #{typeof first}" unless SE_OBJECT_TYPE_STRING is typeof first
    symbol = @.parse_string first
    return null unless symbol?
    return RETURN_NULL_WITH_WARNING "expect symbol as first element of list, but a string: #{first}" unless symbol.type is SE_OBJECT_TYPE_SYMBOL
    return new SE_List tail, symbol, @, lv+1
    # return RETURN_NULL_WITH_WARNING "expect a string with more than 3 characters but only #{first.length} => #{first}" unless first.length >= 3
    # return RETURN_NULL_WITH_WARNING "expect a string as symbol but quoted string" if q0 is \" and q1 is \"
    # xs = [ x for x in list ]
    # key = xs.shift!
    # return RETURN_NULL_WITH_WARNING "first element is not a String" unless SE_OBJECT_TYPE_STRING is typeof key
    # obj = {}

  get: (key) ->
    return @root.dictionary[key]



module.exports = exports = {NetlistParser}
