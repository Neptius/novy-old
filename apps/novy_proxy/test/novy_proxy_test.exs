defmodule NovyProxyTest do
  use ExUnit.Case
  doctest NovyProxy

  test "greets the world" do
    assert NovyProxy.hello() == :world
  end
end
