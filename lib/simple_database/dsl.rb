module SimpleDatabase
  class ConnectorDSL
    attr_reader :tables

    def initialize(&block)
      @tables = {}
      instance_eval &block
    end

    def table(name, &block)
      table_dsl = TableDSL.new(name, &block)
      @tables[name] = Table.new(table_dsl.get_name, table_dsl.get_source, table_dsl.get_columns)
    end

    def method_missing(name, *args, &block)
      raise "Unknow option: #{name}"
    end
  end

  class TableDSL
    def initialize(name, &block)
      @name = name
      @source = {}
      @columns = {}
      instance_eval &block
    end

    def source(type, path)
      @source = {type: type, path: path}
    end

    def column(name, type, size=nil)
      size ||= default_column_size(type)
      @column_index ||= -1
      @column_index = @column_index + 1
      @columns[name] = {type: type, size: size, index: @column_index}
    end

    %w[source name columns].each do |meth|
      define_method "get_#{meth}" do
        instance_variable_get(:"@#{meth}")
      end
    end

    def method_missing(name, *args, &block)
      raise "Unknow option: #{name}"
    end

    private

    def default_column_size(type)
      case type
        when :integer
          8
        when :datetime
          8
        when :string
          255
        else
          raise "Unknown column type: #{type}!"
      end
    end
  end
end