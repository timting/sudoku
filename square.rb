class Square
  attr_accessor :value, :possibilities, :impossibilities, :state, :row, :column, :group

  def initialize(value=nil, row=0, column=0, group=0)
    @value = value
    @row = row
    @column = column
    @group = group
    @state = value ? "set" : "open"
  end

  def value=(value)
    @value = value
    @state = value ? "guessed" : "open"
  end
end
