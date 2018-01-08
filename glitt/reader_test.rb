require 'test/unit'
require_relative 'reader'

# Super basic unit tests for reading functionality.

class TestReader < Test::Unit::TestCase
  def test_read_atom_integer
    reader = Reader.new(['1'])
    assert_equal(1, read_form(reader))
  end

  def test_read_atom_symbol
    reader = Reader.new(['a'])
    assert_equal(:a, read_form(reader))
  end

  def test_read_list_integers
    reader = Reader.new(%w(( 1 2 )))
    assert_equal([1, 2], read_form(reader))
  end

  def test_read_list_mixed
    reader = Reader.new(%w(( a b 1 2 3 )))
    assert_equal([:a, :b, 1, 2, 3], read_form(reader))
  end

  def test_read_nested_list
    reader = Reader.new(%w(( ( 1 2 ) ( 3 4 ) )))
    assert_equal([[1, 2], [3, 4]], read_form(reader))
  end
end
