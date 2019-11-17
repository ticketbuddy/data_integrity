defmodule DataIntegrity do
  @moduledoc """
  Return a signature with data, that can be used to
  detect if it was modified.
  """

  defmacro __using__(salts: salts) do
    quote do
      use DataIntegrity.Signer, salts: unquote(salts)

      def add_signature(data, ttl) when is_map(data) do
        data =
          data
          |> Map.put(:__valid_until__, DataIntegrity.Time.expires_in_timestamp(ttl))

        signature = sign(data)

        data
        |> Map.put(:signature, signature)
      end

      def add_signature(data, ttl) when is_binary(data) do
        signable_content = DataIntegrity.Time.expires_in_timestamp(ttl) <> "." <> data
        signature = sign(signable_content)
        signature <> "." <> signable_content
      end

      def verify(data) do
        with {signature, timestamp, signed_values, content} <- destruct(data),
             true <- valid?(signature, signed_values),
             :ok <- expired(timestamp) do
          {:ok, content}
        else
          :expired ->
            {:error, :signature_expired}

          error ->
            {:error, :invalid_signature}
        end
      end

      def destruct(data) when is_map(data) do
        {signature, signed_data} = Map.pop(data, :signature)
        {timestamp, content} = Map.pop(signed_data, :__valid_until__)

        {signature, timestamp, signed_data, content}
      end

      def destruct(data) when is_binary(data) do
        case String.split(data, ".", parts: 3) do
          [signature, timestamp, content] ->
            {signature, timestamp, timestamp <> "." <> content, content}

          _ ->
            :error
        end
      end

      def expired(expires_at) do
        case DataIntegrity.Time.now() < String.to_integer(expires_at) do
          true -> :ok
          false -> :expired
        end
      end
    end
  end
end
