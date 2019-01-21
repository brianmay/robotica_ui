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
    filename =
      Application.get_env(:robotica_ui, :config_file)
      |> replace_values(substitutions())

    {:ok, data} = YamlElixir.read_from_file(filename)
    {:ok, data} = Robotica.Validation.validate_schema(data, config_schema())
    data
  end

end