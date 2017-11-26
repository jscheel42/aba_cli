defmodule AbaCLITest do
  use ExUnit.Case
  doctest AbaCLI

  test "greets the world" do
    assert AbaCLI.hello() == :world
  end
end
