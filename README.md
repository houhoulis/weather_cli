# Weather CLI

Fetch, parse, and print weather report(s) via the CLI from either of two XML endpoints at [weather.gov](https://w1.weather.gov/xml/current_obs).

## Usage, after building the executable with `mix escript.build`:

    Call with a weather station code to get its weather report, or call with no code
    to get all weather reports. Pass "--full" to get more detailed report(s). When not
    passing a single station code, to get paginated results rather than all 3,000,
    pass "--page x --per-page y" where x and y are positive integers. Pass "--help"
    to get this help.

    Examples:
    ./weather TJBQ
    ./weather TJBQ --full
    ./weather
    ./weather --full
    ./weather --page 102 --per-page 25
    ./weather --page 102 --per-page 25 --full

## Details:

One of the weather.gov endpoints takes a station code in the URL and returns the most recent weather report from that station. Passing a station code on the CLI causes the app to use this endpoint. The other weather.gov endpoint retrieves the most recent report from all stations, and is used by the app if no station code is passed in.

If reports from all stations were fetched, the payload is a zip-formatted file. The app unzips the zipfile in memory, and selects a subset of the reports. The app selects a subset of reports because there appear to be a lot of station reports that are outdated. There is some correlation between report validity and the structure of the report's filename. The app selects the subset of report filenames that seem most likely to contain current station reports.ª

If reports from all stations were fetched and the `--page <x>` and `--per-page <y>` flags were passed in, then the app returns one "page" of results from the full result set. This pagination is done in memory, from the full result set, because the endpoint doesn't support pagination.

The app extracts data from the downloaded report(s) by using either of [two preconfigured lists of fields](config/config.exs) as keys to extract their values from the XML. The default is the shorter of the two preconfigured lists; `--full` can be passed to use the longer list and get a wider table.

The app aligns the data in tabular format by getting, for each field, the length of the longest string from all rows (including the header) for that field. The app pads the header and each value for that field to that length.

ª Note: As of May 14, 2022, the full result set from weather.gov contains about 5100 reports. Only 56% of those are current reports. Many (most?) of the rest are years old. The subset that the app selects contains 88% current reports while only excluding 7 current reports.

#### Origin:

Expanded version of an exercise for ["Programming Elixir"](https://pragprog.com/titles/elixir16/programming-elixir-1-6/), chapter 13, p. 168.

## Todo

* Allow an `--all` flag to return all station reports, not just the subset of reports likeliest to be current.
* Allow a list of fields to be passed in to specify what data to extract from the report XML files.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `weather` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:weather, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/weather>.

