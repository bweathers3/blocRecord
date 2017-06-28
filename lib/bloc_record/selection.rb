
require 'sqlite3'

module Selection

  def find(*ids)
    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end

  def find_one(id)
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE id = #{id};
    SQL

    init_object_from_row(row)
  end

  def find_by(name, addressbookname)
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE #{name} = #{BlocRecord::Utility.sql_strings(addressbookname)};
    SQL

    init_object_from_row(row)
  end

  def method_missing(m, *args, &block)
    if m == :find_by_name
      find_by(:name, *args[0])
    end
    if m == :search
      find_by(:name, *args[0])
    end
    if m == :find_by_batch
      find_in_batches(:name, *args[0])
    end

    throw "Method #{m} not found!!!!"
  end

  def find_each(start_size = {})
    start = start_size.has_key?(:start) ? start_size[:start] : 0
		batch_size = start_size.has_key?(:batch_size) ? start_size[:batch_size] : 2000

    rows = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT batch_size OFFSET start;
    SQL

    yield(rows_to_array(rows))
  end

  def find_in_batches(start_size = {})
    start = start_size.has_key?(:start) ? start_size[:start] : 0
    batch_size = start_size.has_key?(:batch_size) ? start_size[:batch_size] : 2000

    while  i < batches + 1 do
      rows = connection.get_first_row <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        LIMIT batch_size OFFSET start;
      SQL

      yield(rows_to_array(rows))
    end
  end

  def take(num=1)
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT #{num};
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id
      ASC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id
      DESC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table};
    SQL

    rows_to_array(rows)
  end


private
  def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end

  def rows_to_array(rows)
    rows.map { |row| new(Hash[columns.zip(row)]) }
  end
end
