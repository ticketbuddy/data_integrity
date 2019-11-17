defmodule DataIntegrityTest do
  use ExUnit.Case

  import Mox
  setup :verify_on_exit!
  setup :set_mox_global

  setup do
    DataIntegrity.SystemTimeMock
    |> stub(:now, fn ->
      9_999_999_999_999
    end)

    :ok
  end

  defmodule MyDataIntegrity do
    use DataIntegrity,
      salts: [
        "B92TbN3sxHmf6nUGCbRGD/+rnE17U0gleCAFdyLXUZ7oW4ouPQCh6l+QVe7NYY0x"
      ]
  end

  describe "when content is a string" do
    test "add signature to string" do
      signature = MyDataIntegrity.add_signature("ensure-i-a.m-not-chan.ged", {5, :minutes})

      assert signature ==
               "508DB5886D0260DD50A74EF78DE31F48.10000000299999.ensure-i-a.m-not-chan.ged"

      assert {:ok, "ensure-i-a.m-not-chan.ged"} == MyDataIntegrity.verify(signature)
    end

    test "changing timestamp changes signature" do
      signed_5_mins = MyDataIntegrity.add_signature("ensure-i-a.m-not-chan.ged", {5, :minutes})
      signed_6_mins = MyDataIntegrity.add_signature("ensure-i-a.m-not-chan.ged", {6, :minutes})

      [signature_5_mins, _] = String.split(signed_5_mins, ".", parts: 2)
      [signature_6_mins, _] = String.split(signed_6_mins, ".", parts: 2)

      assert byte_size(signature_5_mins) == 32
      assert byte_size(signature_6_mins) == 32

      refute signature_5_mins == signature_6_mins
    end

    test "when signature has expired" do
      DataIntegrity.SystemTimeMock
      |> expect(:now, fn ->
        0
      end)

      signature_string = MyDataIntegrity.add_signature("ensure-i-a.m-not-chan.ged", {6, :minutes})

      assert {:error, :signature_expired} == MyDataIntegrity.verify(signature_string)
    end

    test "when signed content is not correctly formatted expired" do
      signature_string = "foo-bar-i-am-not-secured"

      assert {:error, :invalid_signature} == MyDataIntegrity.verify(signature_string)
    end
  end

  describe "when content is a map" do
    test "adds signature" do
      signed_content = MyDataIntegrity.add_signature(%{a: "b"}, {5, :minutes})

      assert %{
               a: "b",
               signature: "7DDB3AFA3A3E5B9698C6D1C6292B9725",
               __valid_until__: "10000000299999"
             } == signed_content

      assert {:ok, %{a: "b"}} == MyDataIntegrity.verify(signed_content)
    end

    test "when data is expired" do
      DataIntegrity.SystemTimeMock
      |> expect(:now, fn ->
        0
      end)

      signed_content = MyDataIntegrity.add_signature(%{a: "b"}, {5, :minutes})

      assert {:error, :signature_expired} == MyDataIntegrity.verify(signed_content)
    end

    test "when signed content does not contain a expirey" do
      signed_content = %{
        a: "b",
        signature: "7DDB3AFA3A3E5B9698C6D1C6292B9725"
      }

      assert {:error, :invalid_signature} == MyDataIntegrity.verify(signed_content)
    end

    test "when signed content does not contain a expirey or signature" do
      signed_content = %{
        a: "b"
      }

      assert {:error, :invalid_signature} == MyDataIntegrity.verify(signed_content)
    end

    test "detects when timestamp has been changed" do
      signed_content = MyDataIntegrity.add_signature(%{a: "b"}, {5, :minutes})

      signed_content = Map.put(signed_content, :__valid_until__, "999999999")

      assert {:error, :invalid_signature} == MyDataIntegrity.verify(signed_content)
    end
  end
end
