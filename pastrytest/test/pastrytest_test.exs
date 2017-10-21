defmodule PastrytestTest do
  use ExUnit.Case
  doctest Pastrytest

  test "greets the world" do
    assert Pastrytest.hello() == :world
  end
end
