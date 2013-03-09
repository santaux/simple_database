require 'test/unit'
require 'simple_database'

class TestDsl < Test::Unit::TestCase
  def setup
    SimpleDatabase.define_connection :sample do
      table :days do
        source :file, "/tmp/days"

        column :name, :string, 50
        column :number, :integer
        column :date, :datetime
      end

      table :weeks do
        source :file, "/tmp/weeks"
        column :name, :string, 30
        column :number, :integer
      end
    end
  end

  def test_database_connection_existence
    assert_block do
      SimpleDatabase.connections.keys.include? :sample
    end
  end

  def test_tables_existence
    assert_block do
      SimpleDatabase.connections[:sample].tables.keys.include? :days
      SimpleDatabase.connections[:sample].tables.keys.include? :weeks
    end
  end

  def test_days_sources_correctness
    assert_equal SimpleDatabase.connections[:sample].tables[:days].source[:type], :file
    assert_equal SimpleDatabase.connections[:sample].tables[:days].source[:path], '/tmp/days'
  end

  def test_weeks_sources_correctness
    assert_equal SimpleDatabase.connections[:sample].tables[:weeks].source[:type], :file
    assert_equal SimpleDatabase.connections[:sample].tables[:weeks].source[:path], '/tmp/weeks'
  end

  def test_days_columns_correctness
    table = SimpleDatabase.connections[:sample].tables[:days]

    assert_equal table.columns[:name][:type],  :string
    assert_equal table.columns[:name][:size],  50
    assert_equal table.columns[:name][:index], 0

    assert_equal table.columns[:number][:type],  :integer
    assert_equal table.columns[:number][:index], 1

    assert_equal table.columns[:date][:type],    :datetime
    assert_equal table.columns[:date][:index],   2
  end

  def test_weeks_columns_correctness
    table = SimpleDatabase.connections[:sample].tables[:weeks]

    assert_equal table.columns[:name][:type],  :string
    assert_equal table.columns[:name][:size],  30
    assert_equal table.columns[:name][:index], 0

    assert_equal table.columns[:number][:type],  :integer
    assert_equal table.columns[:number][:index], 1
  end
end