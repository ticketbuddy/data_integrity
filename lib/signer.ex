defmodule DataIntegrity.Signer do
  @moduledoc """
  Signs and validates
  """
  defmacro __using__(salts: salts) do
    quote do
      import DataIntegrity.Signer
      @salts unquote(salts)

      def sign(data) do
        data
        |> Notation.notate()
        |> sign_with_salt(get_salt())
      end

      def valid?(signature, content) do
        Enum.any?(@salts, fn salt ->
          notation = Notation.notate(content)
          signature == sign_with_salt(notation, salt)
        end)
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
