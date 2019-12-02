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
  initial := input.toArrayInt()
  final := initial.clone()
  final.execute()
  got := final.toCommaString()
  Stdout.writeLine(format("{} => {} (want {})", initial.toCommaString(), got, want))
  assert(got == want)
}

main() {
  ::currentAllocator = Memory.heapAllocator()

  test()

  sb := StringBuilder{}
  File.tryReadToStringBuilder("./input.txt", ref sb)
  initial := sb.toString().toArrayInt()

  // Part 1: patch input before running:
  // > before running the program, replace position 1 with the value 12 and
  // > replace position 2 with the value 2
  part1 := initial.clone().executeWith(12, 2)
  Stdout.writeLine(format("part 1: noun=12, verb=2: {}", part1))

  // Part 2: find what noun and verb returns 19690720, brute force
  output := 19690720
  for noun := 0; noun <= 99; noun += 1 {
    for verb := 0; verb <= 99; verb += 1 {
      result := initial.clone().executeWith(noun, verb)
      if result == output {
        Stdout.writeLine(format("found noun: {} and verb: {} = {}", noun, verb, result))
        return
      }
    }
  }
}

add(a int, b int) {
  return a + b
}

mul(a int, b int) {
  return a * b
}

// UFCS extensions to the string type.
string {
  toArrayInt(s string) Array<int> {
    values := s.split(',')
    ints := new Array<int>(values.count)
    for val, i in values {
      ints[i] = int.tryParse(val).unwrap()
    }
    return ints
  }
}

// UFCS extensions to the Array type.
Array {
  // executeInstruction executes an instruction by calling op with the inputs 
  // at indices ix1 and ix2, and stores the result at ix3.
  executeInstruction(ints Array<int>, ix1 int, ix2 int, ix3 int, op fun<int, int, int>) {
    maxIx := max(max(ix1, ix2), ix3)
    assert(ints.count > maxIx)
    ints[ix3] = op(ints[ix1], ints[ix2])
  }

  // execute runs the Intcode machine until the end, starting with the
  // operation at index 0, and returns the result at position 0. It 
  // abandons in case of error, printing the reason.
  execute(ints Array<int>) {
    for i := 0; i < ints.count; i += 4 {
      op := ints[i]
      if op == 1 {
        ints.executeInstruction(ints[i+1], ints[i+2], ints[i+3], add)
      } else if op == 2 {
        ints.executeInstruction(ints[i+1], ints[i+2], ints[i+3], mul)
      } else if op == 99 {
        return ints[0]
      } else {
        Stdout.writeLine(format("unknown opcode: {}: {}", i, ints[i]))
        abandon()
      }
    }
    Stdout.writeLine("array overload")
    abandon()
  }

  // executeWith runs the Intcode machine until the end using noun and verb as
  // input (positions 1 and 2 respectively). It returns the value at position
  // 0. It abandons in case of error, printing the reason.
  executeWith(ints Array<int>, noun int, verb int) {
    ints[1] = noun 
    ints[2] = verb
    ints.execute()
    return ints[0]
  }

  // toCommaString formats the integer array as a comma-separated list of
  // values.
  toCommaString(ints Array<int>) string {
    sb := StringBuilder{}
    for v, i in ints {
      sb.write(format("{}", v))
      if i < ints.count - 1 {
        sb.writeChar(',')
      }
    }
    return sb.toString()
  }

  // clone returns a new array that is a copy of the from array.
  clone(from Array<T>) {
    final := new Array<T>(from.count)
    from.copySlice(0, from.count, final, 0)
    return final
  }
}

