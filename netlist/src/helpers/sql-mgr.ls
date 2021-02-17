require! <[debug sqlite3]>
DBG = debug 'sql'
INFO = console.log
TRACE = -> return console.error.apply null, arguments if global.verbose


const SQL_CREATE_TABLE_FOR_COMPONENT = '''
  CREATE TABLE Component (
    id INTEGER,
    designator TEXT,
    rid INTEGER,
    ref TEXT,
    value TEXT,
    footprint TEXT,
    sheetpath TEXT,
    datasheet TEXT,

    OTHER_FIELDS

    PRIMARY KEY("id")
  )
'''


class SqlManager
  (@config={}, @query) ->
    @db = new sqlite3.Database ':memory:'
    return

  load_components: (parser) ->
    {db} = self = @
    {components} = parser
    self.tmp = {}
    default_fields = <[id designator rid ref value footprint sheetpath datasheet]>
    for c in components
      for k, v of c.properties
        self.tmp[k] = v
    extra_fields = [ k for k, v of self.tmp ]
    extra_fields.sort!
    xs = [ "\"#{p}\" TEXT," for p in extra_fields ]
    create_table_sql = SQL_CREATE_TABLE_FOR_COMPONENT.replace 'OTHER_FIELDS', (xs.join '\n  ')
    DBG "table creation: Component => #{create_table_sql}"
    fields = [] ++ default_fields ++ extra_fields
    ys = [ "?" for f in fields ]
    ys = ys.join ', '
    insert_table_sql = "INSERT INTO Component VALUES (#{ys})"
    TRACE "table[Component]: #{fields.join ', '}"
    DBG "table insertion: Component => #{insert_table_sql}"
    db.run create_table_sql
    stmt = db.prepare insert_table_sql
    for c in components
      # DBG "inserting #{c.get_field_value 'ref'}"
      zs = c.get_field_values fields
      stmt.run zs
    stmt.finalize!

  parse_rows: (rows) ->
    return {columns: [], rows: []} if rows.length is 0
    columns = [ k for k, v of rows[0] ]
    return {columns, rows}

  load_and_run: (parser, done) ->
    {db, query} = self = @
    db.serialize ->
      self.load_components parser
      (err, rows) <- db.all query
      db.close!
      return done err if err?
      return done null, (self.parse_rows rows)
    return



module.exports = exports = {SqlManager}