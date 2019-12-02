Tester struct {
  name string
  funs List<fun<Assert, void>>
  fnames List<string>

  cons(name string) {
    return Tester{
      name: name,
      funs: new List<fun<Assert, void>>{},
      fnames: new List<string>{},
    }
  }

  register(t *Tester, name string, fn fun<Assert, void>) {
    t.funs.add(fn)
    t.fnames.add(name)
  }

  run(t *Tester) {
    a := Assert{}

    Stdout.writeLine(format(">> running {}", t.name))
    for fn, i in t.funs {
      nm := t.fnames[i]
      Stdout.writeLine(format(".... {}", nm))
      fn(a)
      Stdout.writeLine(format("PASS {}", nm))
    }
    Stdout.writeLine(format("<< done running {}", t.name))
  }
}

Assert struct {
  fail(a Assert, msg string) {
    Stdout.writeLine(format("FAIL {}", msg))
    abandon()
  }

  assert(a Assert, cond bool, msg string) {
    if !cond {
      a.fail(msg)
    }
  }

  equal<T>(a Assert, expected T, got T) {
    a.assert(expected == got, format("want {}, got {}", expected, got))
  }
}
