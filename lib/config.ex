defmodule RoboticaUi.Config do
  @spec replace_values(String.t(), %{required(String.t()) => String.t()}) :: String.t()
  defp replace_values(string, values) do
    Regex.replace(~r/{([a-z_]+)?}/, string, fn _, match ->
      Map.fetch!(values, match)
    end)
  end

  defp substitutions do
    {:ok, hostname} = :inet.gethostname()
    hostname = to_string(hostname)

    %{
      "hostname" => hostname
    }
  end

  defp config_schema do
    %{
      locations: {{:list, :string}, true}
    }
  end

  def configuration do
    %{locations: ["A", "B", "C"]}
  end
end
