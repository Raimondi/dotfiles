Matrix := Object clone do (
  init := method(
    self lists := list()
  )
  dim := method(x, y,
    theMatrix := Matrix clone
    x repeat(
      yList := Matrix clone
      y repeat(
        yList append(0)
      )
      theMatrix append(yList)
    )
    theMatrix
  )
  // TODO
  \// XXX
  \\// FIXME
  \\\// NOTE
  set := method(x, y, value,
    self at(x) atPut(y, value)
  )
  get := method(x, y,
    @ self at(x) at(y)
  )
  transpose := method(
    x := self at(0) size
    y := self size
    newMatrix := self dim(x,y)
    for(xi, 0, x + 1, 1,
      for(yi, 0, y - 1, 1,
        newMatrix set(xi, yi, self get(yi, xi))
      )
    )
    newMatrix
  )
  toFile := method(name,
    File with(name) open write(self serialized) close
  )
  fromFile := method(name,
    doRelativeFile(name)
  )
)
"abc #{ def  }khasg"
theMatrix := Matrix dim(5,6)
theMatrix set(2,1, 20)
theMatrix get(2,1) println
theMatrix get(1,2) println
theMatrix transpose() get(1,2) println
theMatrix toFile("foo.txt")
newMatrix := Matrix fromFile("foo.txt")
newMatrix get(2,1) println
newMatrix get(1,2) println
newMatrix transpose() get(1,2) println
1 >= 2
