defmodule DataIntegrity.SignerTest do
  use ExUnit.Case

  import Mox
  setup :verify_on_exit!
  setup :set_mox_global

  setup do
    DataIntegrity.SystemTimeMock
    |> stub(:now, fn ->
      1_573_984_376_307
    end)

    :ok
  end

  defmodule MySigner do
    use DataIntegrity.Signer,
      salts: [
        "B92TbN3sxHmf6nUGCbRGD/+rnE17U0gleCAFdyLXUZ7oW4ouPQCh6l+QVe7NYY0x",
        "ATjzRG6NudAw3gckJaw0jWBSPyHVyP9UJXNWunj3rLzpVoHxb1neldZSywH40AWL"
      ]
  end

  test "signs a string" do
    signature = MySigner.sign("hello")

    assert signature in [
             "78835A6F3C1E5BB8D56EC3D1D2253325",
             "2A3A8E6D034E11A6452C900B10F7E2B5"
           ]
  end

  test "signs a map" do
    signature = MySigner.sign(%{})

    assert signature in [
             "8AE56E1ACBFFE26F6761CC07C642C3A7",
             "BBE3BC24AF71DE80A9D99C7D9050F843"
           ]
  end

  test "validates a signature of a map" do
    signature = MySigner.sign(%{a: "b"})
    assert MySigner.valid?(signature, %{a: "b"})
  end

  test "validates a signature of a string" do
    signature = MySigner.sign("hello")
    assert MySigner.valid?(signature, "hello")
  end

  test "detects change using a signature of a map" do
    signature = MySigner.sign(%{a: "b"})
    refute MySigner.valid?(signature, %{c: "d"})
  end

  test "detects change using a signature of a string" do
    signature = MySigner.sign("hello")
    refute MySigner.valid?(signature, "bye")
  end

  test "simples" do
    data = %{a: "b", c: "d"}

    signature = MySigner.sign(data)
    assert MySigner.valid?(signature, data)
  end

  test "order doesn't matter" do
    data = %{a: "b", c: "d"}
    different_order_data = %{c: "d", a: "b"}

    signature = MySigner.sign(data)
    assert MySigner.valid?(signature, different_order_data)
  end

  test "atoms and string keys are equal" do
    data = %{a: "b", c: "d"}
    modified_data = %{"c" => "d", a: "b"}

    signature = MySigner.sign(data)
    assert MySigner.valid?(signature, modified_data)
  end

  test "rejects modified data" do
    data = %{a: "b", c: "d"}
    modified_data = %{a: "u", c: "o"}

    signature = MySigner.sign(data)
    refute MySigner.valid?(signature, modified_data)
  end
end
