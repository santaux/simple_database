
lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "simple_database/version"
require "simple_database/tables"
require "simple_database/dsl"
require "simple_database/query"

module SimpleDatabase extend self
  def define_connection(name, &block)
    connections[name] = ConnectorDSL.new(&block)
  end

  def connections
    @@connections ||= {}
  end

  def connect(name)
    connection = connections[name]
    connection.tables.values.each { |table| table.connect }
    Query.new(connection)
  end
end

# Class alias to pass the test file:
Database = SimpleDatabase
