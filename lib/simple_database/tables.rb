module SimpleDatabase
  class Table
    attr_reader :name, :source, :columns, :is_loaded, :descriptor, :row_size

    def initialize(name, source, columns)
      @name = name
      @source = source
      @columns = columns
    end

    def connect
      unless File.exists? source[:path]
        puts "File #{source[:path]} for table #{name} does not exist! Create empty table file..."
        `touch #{source[:path]}`
      end
      @descriptor ||= File.open(source[:path], "rb")
    end

    def size
      descriptor.stat.size
    end

    def row_size
      columns.values.inject(0) { |sum,column| sum+column[:size] }
    end

    def get_row(index)
      descriptor.pos = index*row_size
      row_binary = descriptor.read(row_size)
      return if row_binary.nil?

      row_array = unpack row_binary
      row_hash = {}
      columns.each do |name, opts|
        row_hash[name] = convert(row_array[opts[:index]], opts[:type])
      end
      row_hash[:offset] = index
      row_hash
    end

    def rows_count
      size / row_size
    end

    private

    def unpack(row)
      unpack_opts = ""
      columns.values.each { |column| unpack_opts += unpack_opt_by_type(column[:type], column[:size]) }
      row.unpack(unpack_opts)
    end

    def unpack_opt_by_type(type,size=nil)
      case type
        when :integer
          "q"
        when :string
          "A#{size}"
        when :datetime
          "q"
      end
    end

    def convert(value, type)
      if type == :datetime
        Time.at(value).to_date
      else
        value
      end
    end
  end
end
