gem 'minitest', '>= 5.0.0'
require 'minitest/autorun'
require_relative 'board'

class BoardTest < Minitest::Test
  def test_grouping_is_accurate_for_first_row
    board = Board.new("")

    assert_equal 1, board.get_group(0, 3)
  end

  def test_grouping_is_accurate_for_third_row
    board = Board.new("")

    assert_equal 8, board.get_group(7, 7)
  end

  def test_getting_all_open_squares_is_accurate
    very_easy_board = "-,8,3,7,4,-,-,-,5\n-,5,-,-,-,6,1,4,7\n7,-,4,5,2,-,-,8,-\n5,-,2,-,-,8,3,9,4\n1,4,-,9,-,5,7,-,-\n-,-,6,-,7,2,5,-,-\n4,-,-,-,9,3,-,5,1\n-,6,1,2,5,-,-,3,-\n3,9,-,8,-,-,2,-,6"

    board = Board.new(very_easy_board)
    assert_equal 36, board.open(:all).count
  end

  def test_getting_all_open_squares_for_sub_group_is_accurate
    very_easy_board = "-,8,3,7,4,-,-,-,5\n-,5,-,-,-,6,1,4,7\n7,-,4,5,2,-,-,8,-\n5,-,2,-,-,8,3,9,4\n1,4,-,9,-,5,7,-,-\n-,-,6,-,7,2,5,-,-\n4,-,-,-,9,3,-,5,1\n-,6,1,2,5,-,-,3,-\n3,9,-,8,-,-,2,-,6"

    board = Board.new(very_easy_board)
    assert_equal 4, board.open(:groups, 0).count
  end

  def test_intersect_square_possibilities_works
    square1 = Square.new()
    square1.possibilities = Set.new(["1", "2", "3", "7", "9"])
    square2 = Square.new()
    square2.possibilities = Set.new(["1", "3", "9", "4"])
    squares = [square1, square2]

    board = Board.new("")

    assert_equal Set.new(["1", "3", "9"]), board.intersect_square_possibilities(squares)
  end

  def test_valid_board_is_valid
    valid_board = "6,8,3,7,4,1,9,2,5\n2,5,9,3,8,6,1,4,7\n7,1,4,5,2,9,6,8,3\n5,7,2,1,6,8,3,9,4\n1,4,8,9,3,5,7,6,2\n9,3,6,4,7,2,5,1,8\n4,2,7,6,9,3,8,5,1\n8,6,1,2,5,7,4,3,9\n3,9,5,8,1,4,2,7,6"

    board = Board.new(valid_board)

    assert board.valid?
  end

  def test_invalid_board_is_invalid
    invalid_board = "6,8,3,7,4,1,9,2,5\n2,5,9,3,8,6,1,4,7\n7,1,4,5,2,9,6,8,3\n5,7,2,1,6,8,3,9,4\n1,4,8,9,3,5,7,6,2\n9,3,6,4,7,2,5,1,8\n4,2,7,6,9,3,8,5,1\n8,6,1,2,5,7,4,3,9\n3,9,5,8,1,4,2,7,7"

    board = Board.new(invalid_board)
    assert_equal false, board.valid?
  end

  def test_solve_on_very_easy_board
    very_easy_board = "-,8,3,7,4,-,-,-,5\n-,5,-,-,-,6,1,4,7\n7,-,4,5,2,-,-,8,-\n5,-,2,-,-,8,3,9,4\n1,4,-,9,-,5,7,-,-\n-,-,6,-,7,2,5,-,-\n4,-,-,-,9,3,-,5,1\n-,6,1,2,5,-,-,3,-\n3,9,-,8,-,-,2,-,6"

    board = Board.new(very_easy_board)
    board.solve

    assert board.valid?
  end

  def test_solve_on_medium_board
    # #227 http://www.puzzles.ca/sudoku_puzzles/sudoku_medium_227.html
    medium_board = "-,-,-,6,-,-,-,-,5\n-,-,8,-,-,3,-,-,-\n3,4,-,-,-,-,-,7,-\n-,5,-,-,1,-,-,-,-\n6,-,9,-,-,4,-,-,-\n-,-,-,7,-,-,8,-,-\n7,-,-,3,-,-,-,9,-\n8,3,-,-,-,1,-,-,-\n-,-,-,-,-,-,2,-,4"

    board = Board.new(medium_board)
    board.solve

    assert board.valid?
  end

  def test_solve_on_medium_board2
    # #151 http://www.puzzles.ca/sudoku_puzzles/sudoku_medium_151.html
    medium_board = "-,-,2,-,-,-,1,-,6\n-,-,-,5,6,-,-,-,-\n-,-,7,-,-,-,-,4,-\n-,-,-,-,-,1,-,6,-\n1,-,3,-,-,2,-,-,7\n-,-,6,-,-,8,-,9,-\n-,-,-,-,-,9,4,-,-\n8,-,-,-,-,-,-,3,-\n-,4,5,-,3,-,-,-,-"

    board = Board.new(medium_board)
    board.solve

    assert board.valid?
  end

  def test_solve_on_hard_board
    # #003 http://www.puzzles.ca/sudoku_puzzles/sudoku_hard_003.html
    hard_board = "1,3,-,2,7,-,-,-,6\n-,6,-,-,-,3,-,2,-\n8,-,9,-,6,-,-,5,-\n4,-,7,9,-,-,2,-,-\n-,-,-,-,1,-,-,-,-\n-,-,-,7,5,-,8,1,-\n9,-,8,5,-,-,7,-,-\n-,-,-,-,-,7,-,9,-\n-,-,1,-,-,-,-,-,-"

    board = Board.new(hard_board)
    board.solve

    assert board.valid?
  end

  def test_solve_on_very_hard_board
    # http://www.7sudoku.com/view-puzzle?date=20160826
    very_hard_board = "-,-,5,-,2,-,-,-,-\n8,-,-,-,-,7,4,-,1\n-,6,-,-,-,-,-,5,-\n-,1,-,-,9,-,-,-,-\n-,7,-,8,-,3,-,6,-\n-,-,-,-,7,-,-,4,-\n-,5,-,-,-,-,-,8,-\n4,-,2,9,-,-,-,-,3\n-,-,-,-,3,-,2,-,-"

    board = Board.new(very_hard_board)
    board.solve

    assert board.valid?
  end

  def test_solve_on_very_hard_board2
    # http://www.7sudoku.com/view-puzzle?date=20160823
    very_hard_board = "-,3,-,-,-,1,9,-,-\n-,-,8,-,6,-,-,-,-\n1,-,-,3,-,-,6,-,2\n8,-,6,-,-,4,-,-,7\n-,-,-,-,-,-,-,-,-\n2,-,-,9,-,-,1,-,4\n5,-,9,-,-,8,-,-,3\n-,-,-,-,3,-,8,-,-\n-,-,3,7,-,-,-,2,-"

    board = Board.new(very_hard_board)
    board.solve

    assert board.valid?
  end
end
