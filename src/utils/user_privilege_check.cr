lib LibC
  fun getuid : Int
end

def root?
    LibC.getuid==0
end
