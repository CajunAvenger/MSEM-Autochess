# An Impact that scales based on the wielder's artifact counts
# Defaults for Alenian Warhammer but others can use it too
class Impact_Warhammer < Impact
  attr_reader :comp_scale       # scale base amount by components
  attr_reader :compl_scale      # scale base amount by completed
  attr_reader :rare_scale       # scale base amount by rare
  
  def initialize(id, amount, cs=1, cos=0, rs=0)
    super(id, amount)
    @comp_scale = cs
    @compl_scale = cos
    @rare_scale = rs
  end
  
  def get_multi
    return 2 unless @target
    vals = @target.artifact_counts
    return  @comp_scale*vals[:component] + @compl_scale*vals[:completed] + @rare_scale*vals[:rare]
  end
  
  def clone_args(new_target)
    return [
      Impact_Warhammer,
      [@id, @amount, @comp_scale, @compl_scale, @rare_scale],
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