class BookResource < ::ApiNavigator::Resources::MemberResource

  def intitialize(representation, entry_point, response=nil)
    super
  end

  def foo
    "bar"
  end
end