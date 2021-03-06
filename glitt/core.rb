# Defining our built-ins
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
  :count => lambda { |a| a.nil? ? 0 : a.count },
}
