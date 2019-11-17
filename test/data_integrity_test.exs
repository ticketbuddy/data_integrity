defmodule DataIntegrityTest do
  use ExUnit.Case
  doctest DataIntegrity

  describe "signs a map data type, and then validates it" do
    test "simples" do
      data = %{a: "b", c: "d"}

      signature = DataIntegrity.sign(data)
      assert DataIntegrity.valid?(signature, data)
    end

    test "order doesn't matter" do
      data = %{a: "b", c: "d"}
      different_order_data = %{c: "d", a: "b"}

      signature = DataIntegrity.sign(data)
      assert DataIntegrity.valid?(signature, different_order_data)
    end

    test "atoms and string keys are equal" do
      data = %{a: "b", c: "d"}
      modified_data = %{"c" => "d", a: "b"}

      signature = DataIntegrity.sign(data)
      assert DataIntegrity.valid?(signature, modified_data)
    end
  end

  describe "detects modifications" do
    test "rejects modified data" do
      data = %{a: "b", c: "d"}
      modified_data = %{a: "u", c: "o"}

      signature = DataIntegrity.sign(data)
      refute DataIntegrity.valid?(signature, modified_data)
    end

    test "rejects modified data types" do
      data = %{a: "b", c: "7"}
      modified_data = %{a: "b", c: 7}

      signature = DataIntegrity.sign(data)
      refute DataIntegrity.valid?(signature, modified_data)
    end
  end

  describe "add_signature/1" do
    test "adds signature to provided map" do
      assert %{
               a: "b",
               signature: signature
             } = DataIntegrity.add_signature(%{a: "b"})

      assert signature in [
               "3BE8E5D87A68AAF9DA3504BD98DC5B53",
               "5B7B9957E9ADE687804932D99F33DBF0",
               "575B5E44E39BDF25F9374CAD15A89061"
             ]
    end

    test "validates signature in map" do
      data_with_signature = DataIntegrity.add_signature(%{c: "d"})
      assert DataIntegrity.valid?(data_with_signature)
    end

    test "rejects incorrect signature in map" do
      data_with_signature = DataIntegrity.add_signature(%{c: "d"})

      refute data_with_signature
             |> Map.put(:signature, "abc")
             |> DataIntegrity.valid?()
    end

    test "detects change in data" do
      data_with_signature = DataIntegrity.add_signature(%{c: "d"})

      refute data_with_signature
             |> Map.put(:z, "abc")
             |> DataIntegrity.valid?()
    end
  end
end
