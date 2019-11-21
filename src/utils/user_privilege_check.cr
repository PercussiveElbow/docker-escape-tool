lib LibC
  fun getuid : Int 
end

def root?
  return LibC.getuid==0
end