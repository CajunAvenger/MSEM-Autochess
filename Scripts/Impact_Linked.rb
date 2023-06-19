# An impact that uses another Impact's get_value() as a mutliplier
# Useful for having several impacts that scale off one value
class Impact_Linked < Impact
  def initialize(id, amount, linked_to)
    super(id, amount)
    add_link(linked_to)
  end
  
  def get_value
    return (@super_multi)*(@multi*@link.get_value()*(@amount+get_add())) - @dec
  end
  
  def add_link(imp)
    # make sure we don't make a loop of links
    if imp.link
      check = [imp]
      curr = imp.link
      loop do
        return false if check.include?(curr)
        check.push(curr)
        curr = curr.link
        break unless curr
      end
    end
    @link = imp
    return true
  end
  
  def clone_args(new_target)
    return [
      Impact_Linked,
      [@id, @amount, @link],
      [
        ["source", @source],
        ["target", new_target],
        ["add", @add],
        ["dec", @dec],
        ["multi", @multi],
        ["super_multi", @super_multi],
        ["buffers", @buffers],
        ["focus", @focus],
        ["link", @link]
      ]
    ]
  end
end