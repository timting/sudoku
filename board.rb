require 'set'
require_relative 'square'
require_relative 'strategies'

class Board
  include Strategies
  POSSIBILITIES = ::Set.new(["1", "2", "3", "4", "5", "6", "7", "8", "9"])
  attr_accessor :squares

  # TODO: Add guards for improper boards
  def initialize(board)
    @squares = {}
    board = board.split("\n").map { |l| l.split(",") }
    row = 0
    board.each do |line|
      column = 0
      line.each do |value|
        value = nil if value == "-"
        group = get_group(row, column)
        square = Square.new(value, row, column, group)
        @squares[[row, column]] = square
        @squares["r#{row}"] ||= []
        @squares["r#{row}"] << square
        @squares["c#{column}"] ||= []
        @squares["c#{column}"] << square
        @squares["g#{group}"] ||= []
        @squares["g#{group}"] << square
        @squares["all"] ||= []
        @squares["all"] << square
        column += 1
      end
      row += 1
    end
  end

  def get_group(row, column)
    row = row_col_group(row)
    column = row_col_group(column)

    row * 3 + column
  end

  # Convert a row/column to what equivalent row/column it would be
  # if rows/cols were groups of three rows/cols.
  def row_col_group(row_or_col)
    if row_or_col < 3
      0
    elsif row_or_col < 6
      1
    elsif row_or_col < 9
      2
    end
  end

  def output
    output = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      []
    ]
    @squares['all'].each do |square|
      output[square.row][square.column] = square.value
    end

    (output.map { |row| row.join(",") }.join("\n"))
  end

  # Nicer output that's easier to reason with
  def to_s
    output = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      []
    ]
    @squares['all'].each do |square|
      output[square.row][square.column] = square.value
    end

    output.map { |row| row.map { |s| s || " " }.join(",") }.each do |row|
      p row
    end
  end

  def valid?
    (0..8).each do |number|
      return false unless (POSSIBILITIES - in_row(number).map(&:value)).count == 0
      return false unless (POSSIBILITIES - in_column(number).map(&:value)).count == 0
      return false unless (POSSIBILITIES - in_group(number).map(&:value)).count == 0
    end

    true
  end

  def solve
    initialize_board
    subgroup_exclusion

    last_open = 999
    while open.count > 0 && open.count < last_open
      last_open = open.count

      # remove possibilities
      mark_naked_twins
      mark_hidden_twins

      #
      subgroup_exclusion
    end

    brute_force_remaining_open_squares if open.count > 0
  end

  def brute_force_remaining_open_squares
    array = []
    p open.count
    p "Looping"
    open.each do |square|
      array << [square.row, square.column, square.possibilities]
    end
    p array
    find_solution(array)
  end

  def find_solution(array)
    i = 0
    while i < array.size && array[i][2].size == 1
      i += 1
    end
    p i if i == 25
    p i if i == 20
    p i if i == 15
    p i if i == 10
    p i if i == 5
    if i == array.size
      return try_solution(array)
    end

    array[i][2].each do |possibility|
      new_array = array.dup.map { |a| a.dup }
      new_array[i][2] = [possibility]
      return true if find_solution(new_array)
    end

    false
  end

  def try_solution(array)
    assign_values_to_squares(array)
    valid?
  end

  def assign_values_to_squares(array)
    array.each do |thing|
      square = a_square(thing[0], thing[1])
      square.value = thing[2].first
    end
  end

  def a_square(row, column)
    squares[[row, column]]
  end

  def in_row(row)
    squares["r#{row}"]
  end

  def in_column(column)
    squares["c#{column}"]
  end

  def in_group(group)
    squares["g#{group}"]
  end

  def open(type=:all, number=0)
    case type
    when :all
      squares["all"].select { |s| s.state == "open" }
    when :groups
      squares["g#{number}"].select { |s| s.state == "open" }
    when :rows
      squares["r#{number}"].select { |s| s.state == "open" }
    when :columns
      squares["c#{number}"].select { |s| s.state == "open" }
    end
  end

  def affected_squares(square)
    (Set.new(open(:rows, square.row)) | Set.new(open(:columns, square.column)) | Set.new(open(:groups, square.group))).to_a - [square]
  end
end
