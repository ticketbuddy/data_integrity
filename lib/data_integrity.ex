defmodule DataIntegrity do
  @moduledoc """
  Return a signature with data, that can be used to
  detect if it was modified.
  """

  defmacro __using__(salts: salts) do
    quote do
      @salts unquote(salts)

      def sign(data) do
        data
        |> Notation.notate()
        |> sign_with_salt(get_salt())
      end

      def add_signature(data) when is_map(data) do
        signature = sign(data)
        Map.put(data, :signature, signature)
      end

      def add_signature(data) when is_binary(data) do
        signature = sign(data)
        signature <> "." <> data
      end

      def verify(data) do
        with {signature, content} <- destruct(data),
             true <- valid?(signature, content) do
          {:ok, content}
        else
          _error ->
            {:error, :invalid_signature}
        end
      end

      def valid?(data) do
        case destruct(data) do
          {signature, data} -> valid?(signature, data)
          _ -> false
        end
      end

      def valid?(signature, data) do
        Enum.any?(@salts, fn salt ->
          notation = Notation.notate(data)
          signature == sign_with_salt(notation, salt)
        end)
      end

      def destruct(data) when is_map(data) do
        Map.pop(data, :signature)
      end

      def destruct(data) when is_binary(data) do
        case String.split(data, ".", parts: 2) do
          [signature, signed_data] -> {signature, signed_data}
          _ -> :error
        end
      end

      defp sign_with_salt(notation, salt) do
        :crypto.hash(:md5, salt <> notation) |> Base.encode16()
      end

      defp get_salt do
        @salts
        |> Enum.shuffle()
        |> Enum.at(0)
      end
    end
  end
end
