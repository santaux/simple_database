require 'test/unit'
require 'simple_database'

class TestQuery < Test::Unit::TestCase
  def setup
    File.delete '/tmp/weeks' if File.exists? '/tmp/weeks'

    File.open("/tmp/weeks", "wb") do |f|
      [*1...52].each do |n|
        5.times do
          f.write(["Week #{n}", n].pack("a30q"))
        end
      end
    end

    SimpleDatabase.define_connection :sample do
      table :weeks do
        source :file, "/tmp/weeks"
        column :name, :string, 30
        column :number, :integer
      end
    end

    @connection = Database.connect(:sample)
  end

  def test_select_with_limit
    result = @connection.select(:weeks, where: { name: "Week 1" }, limit: 2)

    assert_equal result.size, 2
    assert_equal result, [{name: 'Week 1', number: 1, offset: 0}, {name: 'Week 1', number: 1, offset: 1}]
  end

  def test_select_without_limit
    weeks = []
    5.times do |n|
      weeks << {name: 'Week 1', number: 1, offset: n}
    end
    result = @connection.select(:weeks, where: { name: "Week 1" })

    assert_equal result, weeks
  end
end