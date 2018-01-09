# Defining our built-ins
# (question: how would we define non-built-ins, eg standard library?
# I guess we would have a separate initialization step where we execute
# Ruby code on startup to define those stdlib functions?)

NS = {
  :+ => lambda { |a, b| a + b },
  :- => lambda { |a, b| a - b },
  :* => lambda { |a, b| a * b },
  :/ => lambda { |a, b| (a / b).to_i },
  :'=' => lambda { |a, b| a == b }, # todo: make more robust, eg type check
  :< => lambda { |a, b| a < b },
  :> => lambda { |a, b| a > b },
  :<= => lambda { |a, b| a <= b },
  :>= => lambda { |a, b| a >= b },
  :prn => lambda { |a| puts pr_str(a); nil },
  :list => lambda { |*args| args },
  :list? => lambda { |a| a.is_a? Array },
  :empty? => lambda { |a| a.empty? },
  :count? => lambda { |a| a.count },
}

