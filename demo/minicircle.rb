module SmallestEnclosingCircle

  # Ref.: http://www.flipcode.com/archives/Smallest_Enclosing_Spheres.shtml
  def self.calculate(nodes)
    @P = nodes.dup.shuffle! # randomization for faster computation
    return self.sec_recurse(0 ,@P.length, 0)
  end

  def self.sec_recurse(head, p, b)
    r = Float::EPSILON
    c = RVec2.new(0, 0)

    case b
    when 0;
      r = -1.0
    when 1
      r = Float::EPSILON
      c = @P[head-1]
    when 2
      o = @P[head-1]
      a = @P[head-2]
      vec_oa = a - o
      vec_o = 0.5 * vec_oa
      r = vec_o.getLength
      c = o + vec_o
    when 3
      # https://en.wikipedia.org/wiki/Circumscribed_circle
      o = @P[head-1]
      a = @P[head-2]
      b = @P[head-3]
      vec_oa = a - o
      vec_ob = b - o
      r = vec_oa.getLength * vec_ob.getLength * (vec_oa - vec_ob).getLength / (2.0 * RVec2.cross(vec_oa, vec_ob)).abs
      denominator = 2.0 * (RVec2.cross(vec_oa, vec_ob) ** 2)
      axb = RVec2.cross(vec_oa, vec_ob)
      vec_o = (vec_oa.getLengthSq * vec_ob - vec_ob.getLengthSq * vec_oa) 
      vec_o.x, vec_o.y = axb * vec_o.y, -axb * vec_o.x # virtual cross product with (0, 0, |a x b|)

      vec_o = vec_o * (1.0 / denominator)
      c = o + vec_o
      return r, c
    end

    for i in 0 ... p
      p_i = @P[head+i]
      if (p_i - c).getLengthSq - r*r > 0
        i.step(to: 1, by: -1) do |j|
          @P[head+j], @P[head+j-1] = @P[head+j-1], @P[head+j]
        end
        r, c = self.sec_recurse(head+1, i, b+1)
      end
    end

    return r, c
  end

end
