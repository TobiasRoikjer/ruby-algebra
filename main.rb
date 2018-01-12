require 'set'

class Group < Array
  def initialize(set, op)
    @set = set
    @op = op
  end

  attr_reader :set, :op

  def inspect
    "(#{@set}, #{@op})"
  end


  def [](n)
    GroupElement.new(@set.find{|e| e == n}, op)
  end
end

class GroupElement
  def initialize(me, op)
    @me = me
    @op = op
  end

  attr_reader :me

  def +(other)
    self * other
  end

  def *(other)
    GroupElement.new(@op.call(me, other.me), @op)
  end

  def to_s
    "(#{@me}, #{@op})"
  end
end

def z_mod_n(n)
  a = Array (0..(n-1))
  Group.new(a, lambda {|q, r| (q + r) % n })
end

def z_mod_n_star(n)
  x = z_mod_n(n)
  Group.new(x.set.select {|e| e.gcd(n) == 1}, x.op)
end

def CRT(*args)
  length = args.length
  a = []
  n = []
  nn = 1

  args.each do |arg|
    a_, n_ = arg
    a << a_
    n << n_

    nn *= n_

    puts "X ≡ #{a_} (mod #{n_})"
  end

  puts "N = #{nn}"

  puts ""

  aa = []

  length.times do |i|
    l = n[i]
    u = nn/n[i]

    ll,uu = _CRT(l,u)

    puts "L_#{i+1} = #{ll}, U_#{i+1} = #{uu} => #{l}L_#{i+1}+#{u}U_#{i+1} = 1"

    aa << uu*u
  end

  xx = 0
  puts ""

  puts "A_j = u_j(N/n_j)"

  length.times do |i|
    puts "A_#{i+1} = #{aa[i]}"
    xx += aa[i]*a[i]
  end

  puts ""
  puts "X=a_1A_1+...+a_tA_t"
  puts "X=#{xx}"
  puts "X'=[X]_#{nn}=#{xx % nn}"
end

def _CRT(l,u)
  100.times {|i| i.times {|j| ll = -j; i.times {|k| uu = k; if l*ll + u*uu == 1
                                                              return [ll,uu]
                                                         end}}}
end

def exp_mod(n,x,m)
  n_s = n % m
  (x-1).times {n = n*n_s % m}
  n
end

class Cycle
  attr_reader :cycle

  def initialize(*args)
    @cycle = args
  end

  def apply(n)
    unless cycle.include?(n)
      return n
    end

    index = cycle.index(n)+1

    if index == cycle.length
      index = 0
    end

    cycle[index]
  end

  def mul(c)
    left = (cycle + c.cycle).uniq
    list = []

    until left.empty?
      cu = []
      n = left.delete_at(0)
      cu << n

      x = n

      while true
        t = apply(c.apply(x))

        left.delete(t)

        if t == cu[0]
          break
        end

        cu << t

        x = t
      end

      list << cu
    end

    list
  end
end