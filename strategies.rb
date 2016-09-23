module Strategies
  POSSIBILITIES = ::Set.new(["1", "2", "3", "4", "5", "6", "7", "8", "9"])

  # Initialization
  def initialize_board
    open.each do |square|
      populate_possibilities(square)
      if square.possibilities.count == 1
        square.value = square.possibilities.first

        update_square_possibilities(square)
      end
    end
  end

  # Subgroup exclusion
  def subgroup_exclusion
    open.each do |square|
      if square.possibilities.count == 1
        square.value = square.possibilities.first

        update_square_possibilities(square)
        next
      end

      [
        {
          :type => :groups,
          :number => square.group
        },
        {
          :type => :rows,
          :number => square.row
        },
        {
          :type => :columns,
          :number => square.column
        }
      ].each do |obj|
        squares = open(obj[:type], obj[:number]) - [square]
        if squares.count > 0
          must_be = intersect_square_impossibilities(squares) - square.impossibilities
          if must_be.count == 1
            square.value = must_be.first
            update_square_possibilities(square)
          end
        end
        break if square.value
      end
    end
  end

  # Naked twins
  def mark_naked_twins
    [:groups, :rows, :columns].each do |type|
      (0..8).each do |number|
        n_twins = {}

        #p "Checking #{type} number #{number}"
        open_squares = open(type, number)
        open_squares.each do |square|
          store_naked_twins(square, n_twins)
        end

        n_twins.each do |comb, squares|
          leftover_squares = open_squares - squares

          if comb.count == squares.count
            leftover_squares.each do |square|
              square.possibilities = square.possibilities - comb
              populate_possibilities(square)
            end
            break
          end
        end
      end
    end
  end

  # Store possibilities to find naked twins
  # http://www.sudokudragon.com/tutorialnakedtwins.htm
  def store_naked_twins(square, n_twins)
    pv = square.possibilities
    return if pv.count == 1

    n_twins[pv.to_a] ||= []
    n_twins[pv.to_a] << square
  end

  # Hidden twins
  def mark_hidden_twins
    [:groups, :rows, :columns].each do |type|
      (0..8).each do |number|
        h_twins = {}

        #p "Checking #{type} number #{number}"
        open_squares = open(type, number)
        open_squares.each do |square|
          store_hidden_twins(square, h_twins)
        end

        h_twins.each do |comb, squares|
          leftover_squares = open_squares - squares
          next if leftover_squares.empty?
          if comb.count == squares.count && (union_square_possibilities(leftover_squares) & comb).empty?
            squares.each do |square|
              square.possibilities = Set.new(comb)
              populate_possibilities(square)
            end
          end
        end
      end
    end
  end

  # Store all combinations of values 2 elements and above so we can find
  # hidden twins: http://www.sudokudragon.com/tutorialhiddentwins.htm
  def store_hidden_twins(square, h_twins)
    pv = square.possibilities

    (2..pv.count).each do |size|
      pv.to_a.combination(size).each do |comb|
        h_twins[comb] ||= []
        h_twins[comb] << square
      end
    end
  end

  # Helper methods
  def update_square_possibilities(square)
    affected_squares(square).each do |a_square|
      populate_possibilities(a_square)
    end
  end

  def intersect_square_possibilities(squares)
    squares.map(&:possibilities).reduce(:&)
  end

  def union_square_possibilities(squares)
    squares.map(&:possibilities).reduce(:|)
  end

  def intersect_square_impossibilities(squares)
    squares.map(&:impossibilities).reduce(:&)
  end

  def populate_possibilities(square)
    possible_in_row = POSSIBILITIES - in_row(square.row).map(&:value)
    possible_in_column = POSSIBILITIES - in_column(square.column).map(&:value)
    possible_in_group = POSSIBILITIES - in_group(square.group).map(&:value)

    # This allows the naked twins/hidden twins removal of possibilities to be retained
    square.possibilities = if square.possibilities
      square.possibilities & possible_in_row & possible_in_column & possible_in_group
    else
      possible_in_row & possible_in_column & possible_in_group
    end

    square.impossibilities = POSSIBILITIES - square.possibilities
  end
end
