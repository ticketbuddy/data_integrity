defmodule DataIntegrity.SystemTime do
  @callback now() :: Integer.t()

  def now do
    :os.system_time(:millisecond)
  end
end

defmodule DataIntegrity.Time do
  @sys_time Application.get_env(:data_integrity, :time, DataIntegrity.SystemTime)

  def timestamp_now_as_string do
    Integer.to_string(@sys_time.now())
  end

  def now() do
    @sys_time.now()
  end

  def expires_in_timestamp(ttl) do
    Integer.to_string(@sys_time.now() + to_milliseconds(ttl))
  end

  defp to_milliseconds({num, :minutes}) do
    num * 60000
  end
end
