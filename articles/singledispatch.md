# Function Overloading with functools

28th Sept 2021

A lesser-known feature that Python has is the ability to overload functions & methods (well… sort of… 😁)

In Python's stdlib `functools` there's a decorator called
[singledispatch](https://docs.python.org/3/library/functools.html#functools.singledispatch) which allows you to create a
"single dispatch generic function". ie it uses the type of the first argument to determine which version of the function
to use (essentially overloading based on the first argument).

For example, the following code:

```python
import functools


class Dog:
    ...


class Cat:
    ...


class Cow:
    ...


@functools.singledispatch
def noise(arg):
    print("Err.. beep boop?")


@noise.register
def _(arg: Dog):
    print("Woof!")


@noise.register
def _(arg: Cat):
    print("Meow!")


noise(Dog())
noise(Cat())
noise(Cow())
```

produces:

```
Woof!
Meow!
Err.. beep boop?
```
