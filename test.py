import sys
import os


def test(foo: int):
    something = 5
    otherthing = 6
    # Something
    test = ["something", "other", 1, 10]
    x = 0
    for i in range(foo):
        if something != otherthing:
            something += 1
    print(test)


test("test")
