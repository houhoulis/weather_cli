defmodule Weather.ReportFormatter do

  @short_report_fields Application.get_env(:weather, :short_report_fields)
  @longer_report_fields Application.get_env(:weather, :longer_report_fields)

  def format_reports(reports, [full: true]) do
    format_with_headers(reports, @longer_report_fields)
  end

  def format_reports(reports, _) do
    format_with_headers(reports, @short_report_fields)
  end

  def format_with_headers(reports, headers) do
    with rows = Enum.map(reports, &extract_fields(&1, headers)),
      rows_with_headers = [headers | rows],
      column_widths = widths_from(rows_with_headers)
    do
      rows_with_headers
      |> Enum.map(&Enum.zip(&1, column_widths))
      |> Enum.map(&format_row(&1))
      |> Enum.join("\n")
    end
  end


  def widths_from(rows) do
    widths = List.duplicate(0, length(List.first(rows)))

    Enum.reduce(
      rows,
      widths,
      fn row, accum ->
        Enum.map(
          Enum.zip(
            Enum.map(row, &String.length(&1)),
            accum
          ),
          fn {element_length, max_width} -> max(element_length, max_width) end
        )
      end
    )
  end

  def extract_fields(report, fields) do
    fields
    |> Enum.map(&extract_field(&1, report))
  end

  defp extract_field(field, report) do
    with regex = ~r(</?#{field}>) do
      Regex.split(regex, report, parts: 3)
      |> Enum.at(1)
      |> to_string()
    end
  end

  defp format_row(row_with_widths) do
    row_with_widths
    |> Enum.map(fn {field, width} -> String.pad_trailing(field, width) end)
    |> Enum.join(" | ")
  end
end
