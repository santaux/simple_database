module SimpleDatabase
  class Query
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def select(table_name, opts={})
      tbl = table(table_name)
      column, value = where_opts(opts)
      limit = limit_opts(opts)
      result = []

      (0..tbl.rows_count-1).each do |i|
        row = tbl.get_row i

        if row[column] == value
          result << row

          if limit
            limit = limit - 1
            break if limit.zero?
          end
        end
      end

      result
    end

    private

    def limit_opts(opts)
      opts[:limit]
    end

    def where_opts(opts)
      column = opts[:where].keys.first
      value = opts[:where].values.first
      [column, value]
    end

    def table(name)
      @connection.tables[name]
    end
  end
end