defmodule Weather.CLI do

  import Weather.WeatherGov, only: [fetch: 1, fetch_all: 1]
  import Weather.ReportFormatter, only: [format_reports: 2]

  @help """
  Call with a weather station code to get its weather report, or call with no code
  to get all weather reports. Pass "--full" to get more detailed report(s). When not
  passing a single station code, to get paginated results rather than all 3,000,
  pass "--page x --per-page y" where x and y are positive integers. Pass "--help"
  to get this help.

  Examples:
  ./weather TJBQ --full
  ./weather --full
  ./weather --page 102 --per-page 25
  """

  def main(argv) do
    parsed_args = parse_argv(argv)
    full_option = elem(parsed_args, 0) |> Keyword.take([:full])

    parsed_args
    |> halt_if_help
    |> go_fetch
    |> format_results(full_option)
    |> print_results
  end

  def parse_argv(argv) do
    OptionParser.parse(
      argv,
      strict: [help: :boolean, page: :integer, per_page: :integer, full: :boolean],
      aliases: [h: :help]
    )
  end

  def halt_if_help(parsed) do
    if parsed |> elem(0) |> Keyword.get(:help) do
      IO.puts(@help)
      System.halt(0)
    end
    parsed
  end

  def go_fetch({_, [code], _}) do
    fetch(code)
  end

  def go_fetch({options, [], _}) do
    fetch_all(options)
  end

  def format_results(list_of_reports, full_option) when is_list(list_of_reports) do
    format_reports(list_of_reports, full_option)
  end

  def format_results({:error}, _) do
    "Sorry!!!!!!!!!"
  end

  def print_results(results) do
    IO.puts(results)
  end
end
