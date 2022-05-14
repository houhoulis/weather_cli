defmodule Weather.WeatherGov do
  require Logger

  @user_agent [{"User-agent", "Elixir Chris"}]
  @gov_url Application.get_env(:weather, :gov_url)

  # A partially-accurate filter. There seem to be a lot of station reports that are
  # from "Unknown Station" and/or haven't been updated in years. This regex was
  # derived by reading a bunch of reports and then guessing at patterns of outdated
  # filenames.
  # Without the regex, 56% of the reports are current. With the regex, 88% of the
  # reports are current, and only 7 current reports are lost.
  @valid_station_filename ~r|\A[A-Z][A-Z0-9]{3}\.xml\z|

  def fetch_all(options \\ []) do
    url(:all)
    |> HTTPoison.get(@user_agent)
    |> handle_all(options)
  end

  def fetch(station_code) do
    url(station_code)
    |> HTTPoison.get(@user_agent)
    |> handle_station
  end

  defp url(:all) do
    "#{@gov_url}/all_xml.zip"
  end

  defp url(station_code) do
    "#{@gov_url}/#{station_code}.xml"
  end

  defp handle_station({:ok, %{status_code: 200, body: body}}) do
    [body]
  end

  defp handle_station({:ok, %{status_code: 404}}) do
    IO.puts("Not found )-;")
    {:error}
  end

  defp handle_station({:error, %{reason: reason}}) do
    Logger.error("Error response: #{reason}")
    {:error}
  end

  def handle_all({:ok, %{status_code: 200, body: body}}, options) do
    {:ok, list_of_reports} = :zip.unzip(body, [:memory])

    valid_count_log_note =
      fn list -> IO.puts("There are #{length(list)} reports believed valid") ; list end

    list_of_reports
    |> believed_valid_texts
    |> valid_count_log_note.()
    |> paginate(options[:page], options[:per_page])
  end

  def handle_all({:error, %{reason: reason}}, _) do
    Logger.error("Error response: #{reason}")
    {:error}
  end

  defp believed_valid_texts(reports) do
    reports
    |> Enum.filter(
        fn {filename, _report} -> Regex.match?(@valid_station_filename, to_string(filename)) end
      )
    # |> Enum.map(&elem(&1, 1))
    |> Enum.map(fn {_filename, report} -> report end)
  end

  defp paginate(list, page, per_page) when is_integer(page) and page > 0 and is_integer(per_page) and per_page > 0 do
    with start = (page - 1) * per_page,
      finish = start + per_page - 1
    do
      Enum.slice(list, start..finish)
    end
  end

  defp paginate(list, _, _), do: list
end
