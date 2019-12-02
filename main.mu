test() {
  Stdout.writeLine(">>> TEST")
  testCase("1,0,0,0,99", "2,0,0,0,99")
  testCase("2,3,0,3,99", "2,3,0,6,99")
  testCase("2,4,4,5,99,0", "2,4,4,5,99,9801")
  testCase("1,1,1,4,99,5,6,0,99", "30,1,1,4,2,5,6,0,99")
  testCase("1,9,10,3,2,3,11,0,99,30,40,50", "3500,9,10,70,2,3,11,0,99,30,40,50")
  Stdout.writeLine("<<< TEST")
}

testCase(input string, want string) {
  initial := strToArrayInt(input)
  final := Array<int>(initial.count)
  initial.copySlice(0, initial.count, ref final, 0)
  runLoop(ref final)
  got := arrayIntToStr(ref final)
  Stdout.writeLine(format("{} => {} (want {})", arrayIntToStr(initial), got, want))
  assert(got == want)
}

main() {
  ::currentAllocator = Memory.heapAllocator()

  test()

  sb := StringBuilder{}
  File.tryReadToStringBuilder("./input.txt", ref sb)
  initial := strToArrayInt(sb.toString())

  // Part 1: patch input before running:
  // > before running the program, replace position 1 with the value 12 and
  // > replace position 2 with the value 2
  part1 := runWith(newArray(initial), 12, 2)
  Stdout.writeLine(format("part 1: noun=12, verb=2: {}", part1))

  // Part 2: find what noun and verb returns 19690720, brute force
  output := 19690720
  for noun := 0; noun <= 99; noun += 1 {
    for verb := 0; verb <= 99; verb += 1 {
      result := runWith(newArray(initial), noun, verb)
      if result == output {
        Stdout.writeLine(format("found noun: {} and verb: {} = {}", noun, verb, result))
        return
      }
    }
  }
}

newArray(from Array<int>) {
  final := new Array<int>(from.count)
  from.copySlice(0, from.count, final, 0)
  return final
}

runWith(ints Array<int>, noun int, verb int) {
  ints[1] = noun 
  ints[2] = verb
  runLoop(ints)
  return ints[0]
}

strToArrayInt(s string) Array<int> {
  values := s.split(',')
  ints := new Array<int>(values.count)
  for val, i in values {
    ints[i] = int.tryParse(val).unwrap()
  }
  return ints
}

arrayIntToStr(ints Array<int>) string {
  sb := StringBuilder{}
  for v, i in ints {
    sb.write(format("{}", v))
    if i < ints.count - 1 {
      sb.writeChar(',')
    }
  }
  return sb.toString()
}

add(a int, b int) {
  return a + b
}

mul(a int, b int) {
  return a * b
}

execute(ints Array<int>, src1 int, src2 int, dst int, op fun<int, int, int>) {
  maxIx := max(max(src1, src2), dst)
  assert(ints.count > maxIx)
  ints[dst] = op(ints[src1], ints[src2])
}

runLoop(ints Array<int>) {
  for i := 0; i < ints.count; i += 4 {
    op := ints[i]
    if op == 1 {
      execute(ints, ints[i+1], ints[i+2], ints[i+3], add)
    } else if op == 2 {
      execute(ints, ints[i+1], ints[i+2], ints[i+3], mul)
    } else if op == 99 {
      return
    } else {
      Stdout.writeLine(format("unknown opcode: {}: {}", i, ints[i]))
      return
    }
  }
  Stdout.writeLine("array overload")
}
