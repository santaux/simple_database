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
