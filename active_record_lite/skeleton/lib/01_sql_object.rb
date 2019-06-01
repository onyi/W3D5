require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @res ||= DBConnection.execute2(<<-SQL)
      SELECT * 
      FROM #{self.table_name}
    SQL
    @res.first.map {|col| col.parameterize.underscore.to_sym }
  end

  def self.finalize!
    @table_name = "#{self.name.downcase}s"
    self.columns.each do |col|
      define_method("#{col}") { self.attributes[col] }
      define_method("#{col}=") { |val| self.attributes[col] = val }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name.nil? ? "#{self.name.downcase}s" : @table_name
    # ...
  end

  def self.all
    res = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL
    self.parse_all(res)
  end

  def self.parse_all(results)
    # ...
    results.map do |res|
      self.new(res)
    end
  end 

  def self.find(id)
    # ...
    self.all.find { |ele| ele.id == id }
  end

  def initialize(params = {})
    params.each do |k,v|
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      send("#{k}=", v)
    end

  end

  def attributes
    # ...
    @attributes ||= Hash.new { |k,v| k[v] = nil}

  end

  def attribute_values
    @attributes.values
  end

  def insert
    # p attribute_values
    # p self.class.columns.length
    # p (["?"] * (self.class.columns.length - 1)).join(",")
    res = DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
      #{self.class.table_name}
      ( #{ self.class.columns[1..-1].map(&:to_s).join(",") })
      VALUES 
      ( #{ (["?"] * (self.class.columns.length - 1)).join(",") }  )
    SQL
    id = DBConnection.last_insert_row_id
    @attributes[:id] = id
  end

  def update
    # ...
  end

  def save

    self.class.all.any? do |row|
      p row.attribute_values
      p @attributes
      p row.attribute_values && attribute_values
      # attribute_values.include?()
    end
  end
end
