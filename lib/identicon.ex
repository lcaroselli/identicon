defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  # def pick_color(image) do
  #   # %Identicon.Image{hex: hex_list} = image
  #   # # pattern matching on the struct -- the image we're getting is an Identicon.Image
  #   # # struct with the hex property which has a value of a list of numbers
  #   # [r, g, b | _rest] = hex_list

  #   # [r, g, b]

  #   %Identicon.Image{hex: [r, g, b | _rest]} = image
  #   # pulling out r, g, b through pattern matching

  #   # next, update the struct with the color property, otherwise it will default to nil
  #   %Identicon.Image{image | color: {r, g, b}}
  # end

  def pick_color(%Identicon.Image{hex: [r, g, b | _rest]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map(grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end)

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row([first, second | _rest] = row) do
    row ++ [second, first]
  end
end
