require 'date'
require 'simple_database'

File.delete '/tmp/days' if File.exists? '/tmp/days'
File.delete '/tmp/weeks' if File.exists? '/tmp/weeks'

# Class alias to pass the test file:
Database = SimpleDatabase

# Write some ruby code to pass the test below.
# It is desirable to use only the stdlib to perform this task.
#
# Additional task:
# - wrap it up in a ruby gem,
# - cover it with your own test.

File.open("/tmp/days", "wb") do |f|
  [*1...300].each do |n|
    3.times do
      f.write(["Day #{n}", n, Date.ordinal(2012, n).to_time.to_i].pack("a50qq"))
    end
  end
end

def assert_equal(expected, given)
  raise "Assertion failed" unless expected == given
  puts "w00t!"
end

Database.define_connection :sample do
  table :days do
    # It's a binary file without any separators,
    # each record is a fixed-size bytes sequence.
    # (do not care about file validity)
    source :file, "/tmp/days"

    # column name, type and size in bytes
    # (do not care about multibyte charsets, 1 char = 1 byte)
    column :name, :string, 50

    # some types has default size
    column :number, :integer
    column :date, :datetime
  end

  table :weeks do
    source :file, "/tmp/weeks"
    column :name, :string, 30
    column :number, :integer
  end
end

connection = Database.connect(:sample)
result = connection.select(:days, where: { name: "Day 117" }, limit: 1)

# `offset` is a record position in a source file
assert_equal [{ name: "Day 117", number: 117, date: Date.ordinal(2012, 117), offset: 348 }], result